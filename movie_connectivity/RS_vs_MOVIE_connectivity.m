clear all
%close all

%--------------------------------------------%
%_____________PARAMETERS TO SET______________%

funcDataType = 'RST';
mistimedMovie = 0;
numShuffles = 100;
dataLength = 40;
framesToSkip = 4;
useDilMasks = 1;
demeanData = 1;
plotMatrices = 0;
binNet = 0;
plotAvStdCorrMat = 0;
plotNetParams = 0;

%--------------------------------------------%

%% read in functional data - both datasets contain 400 volumes which is 10 repeats of 56 secs
% read in RS data 
if funcDataType == 'RST'
    RSdataStruct = MRIread('RS/raw_data_lowpass.nii.gz');
    RSstartVol = 1;
    RSendVol = 401;
    funcData = RSdataStruct.vol(:,:,:,RSstartVol:RSendVol);
    clear RSdataStruct;
elseif funcDataType == 'MOV'
    % read in MOVIE data and correct timing
    MOVIEdataStruct = MRIread('MOVIE/raw_data_lowpass.nii.gz');
    if true(mistimedMovie)
        MOVIEstartVol = 20;
        MOVIEendVol = 420;
    else
        MOVIEstartVol = 40;
        MOVIEendVol = 440;
    end
    funcData = MOVIEdataStruct.vol(:,:,:,MOVIEstartVol:MOVIEendVol);
    clear MOVIEdataStruct;
end

%% read in ROI, and dilate if not already done
load('../reorderedFreeSurferRois.mat');
lobeStartInds = [1 13 18 25 29 35 47 52 59 63];
if funcDataType == 'RST'
    directory = 'RS';
elseif funcDataType == 'MOV'
    directory = 'MOVIE';
end

if ~(exist([directory '/reg_aparc+aseg_to_ref_dilated_4D.nii.gz'], 'file'))
    disp('Creating dilated ROI')
    rois = MRIread([directory '/reg_aparc+aseg_to_ref.nii.gz']);
    roiVol = rois.vol;
    
    numRois = size(roiValsReordered, 1);
    roiInds = cell(numRois, 1);
    roiMasks = zeros(size(funcData, 1), size(funcData, 2),size(funcData, 3), numRois);
    roiDilInds = cell(numRois, 1);
    roiDilMasks = zeros(size(roiVol, 1), size(roiVol, 2), size(roiVol, 3), numRois);
    % setup structuring element for dilating masks
    NHOOD = zeros(3,3,3);
    NHOOD(2,2,1) = 1;
    NHOOD(2,1:3,2) = 1;
    NHOOD(1:3,2,2) = 1;
    NHOOD(2,2,3) = 1;
    se = strel('arbitrary', NHOOD);
    % dilate ROIs
    for roi = 1:numRois
        disp(sprintf('Dilating ROI %i of %i', roi, numRois));
        % find ROI subs
        roiInds{roi} = find(roiVol == roiValsReordered(roi));
        [roix,roiy,roiz] = ind2sub(size(roiVol), roiInds{roi});
        for ii = 1:length(roix)
            roiMasks(roix(ii),roiy(ii),roiz(ii), roi) = 1;
        end
        % dilate ROI and find new subs
        roiDilMasks(:,:,:,roi) = imdilate(roiMasks(:,:,:,roi), se);
        roiDilInds{roi} = find(roiDilMasks(:,:,:,roi));   
    end
    roisDil = rois;
    roisDil.vol = roiDilMasks;
    roisDil.volsize = [rois.volsize numRois];
    roisDil.volres = [rois.volres 1];
    roisUndil = roisDil;
    roisUndil.vol = roiMasks;
    MRIwrite(roisDil, [directory '/reg_aparc+aseg_to_ref_dilated_4D.nii.gz'], 'int');
    MRIwrite(roisUndil, [directory '/reg_aparc+aseg_to_ref_undilated_4D.nii.gz'], 'int');
else
    rois = MRIread([directory '/reg_aparc+aseg_to_ref_undilated_4D.nii.gz']);
    roisDil = MRIread([directory '/reg_aparc+aseg_to_ref_dilated_4D.nii.gz']);
    roiMasks = rois.vol;
    roiDilMasks = roisDil.vol;
    numRois = size(roiMasks, 4);
    roiInds = cell(numRois, 1);
    roiDilInds = cell(numRois, 1);
    for roi = 1:numRois
        roiInds{roi} = find(roiMasks(:,:,:,roi));
        roiDilInds{roi} = find(roiDilMasks(:,:,:,roi));
    end
end

%% calculate mean timeseries for each ROI for RS data
% setup framesize and frequency of sampling
numFrames = ceil((size(funcData, 4)-dataLength)/framesToSkip);
meanroiTS = zeros(length(roiValsReordered), dataLength, numFrames);
meanroiTSResids = zeros(size(meanroiTS));
frame = 1;
for dataStart = 1:framesToSkip:size(funcData, 4)-dataLength
    disp(sprintf('Calculating mean timeseries for frame %i of %i', frame, numFrames));
    dataEnd = (dataStart-1)+dataLength;
    %calculate mean timecourse for each ROI
    for roi = 1:numRois
        % use dilated masks if required
        if true(useDilMasks)
            allRoiTS = zeros(length(roiDilInds{roi}), dataLength);
            [roiDilX, roiDilY, roiDilZ] = ind2sub([size(roiMasks, 1), size(roiMasks, 2), size(roiMasks, 3)], roiDilInds{roi});
            for ii = 1:size(allRoiTS, 1)
                allRoiTS(ii,1:dataLength) = squeeze(funcData(roiDilX(ii),roiDilY(ii),roiDilZ(ii),dataStart:dataEnd));
            end
            meanroiTS(roi, :, frame) = mean(allRoiTS);
        else
            allRoiTS = zeros(length(roiInds{roi}), dataLength);
            [roiX, roiY, roiZ] = ind2sub([size(roiMasks, 1), size(roiMasks, 2), size(roiMasks, 3)], roiInds{roi});
            for ii = 1:size(allRoiTS, 1)
                allRoiTS(ii,1:dataLength) = squeeze(funcData(roiX(ii),roiY(ii),roiZ(ii),dataStart:dataEnd));
            end
            meanroiTS(roi, :, frame) = mean(allRoiTS);
        end
    end
    % demean data if required and calculate Correlation and Z matrices
    if true(demeanData)
        commonSignal = mean(squeeze(meanroiTS(:,:,frame)), 1)';
        for roi = 1:size(roiValsReordered, 1)
            Y = squeeze(meanroiTS(roi,:,frame))';
            [B, BINT, R] = regress(Y, [commonSignal ones(size(commonSignal))]);
            meanroiTSResids(roi,:, frame) = R;
        end
    end
    
    % advance to next frame
    frame = frame + 1;
end

%% generate correlation matrices
% for resting state data just calculate concomitant correlation
if funcDataType == 'RST'
    corrMatConcomit = zeros(size(meanroiTSResids, 1), size(meanroiTSResids, 1), numFrames);
    zmatConcomit = zeros(size(meanroiTSResids, 1), size(meanroiTSResids, 1), numFrames);
    for frame = 1:numFrames
        corrMatConcomit(:,:,frame) = corr(meanroiTSResids(:,:,frame)');
        zmatConcomit(:,:,frame) = atanh(corrMatConcomit(:,:,frame));
        if true(plotMatrices)
            figure(1)
            subplot(numFrames/2, 2, frame)
            imagesc(zmatConcomit(:,:,frame));
            title(sprintf('RS Correlation Matrix %i of %i', frame, size(zmatConcomit, 3)));
            caxis([-1 1])
            hold on
            for ii = 1:length(lobeStartInds)
                plot([0 size(zmatConcomit, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
                plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmatConcomit, 1)+0.5],  'k')
            end
        end
    end
    
% for movie data we need both concomitant and shuffled correlations
elseif funcDataType == 'MOV'
    corrMatConcomit = zeros(size(meanroiTSResids, 1), size(meanroiTSResids, 1), numFrames);
    zmatConcomit = zeros(size(meanroiTSResids, 1), size(meanroiTSResids, 1), numFrames);
    for frame = 1:numFrames
        corrMatConcomit(:,:,frame) = corr(meanroiTSResids(:,:,frame)');
        zmatConcomit(:,:,frame) = atanh(corrMatConcomit(:,:,frame));
        if true(plotMatrices)
            figure(2)
            subplot(numFrames/2, 2, frame)
            imagesc(zmatConcomit(:,:,frame));
            title(sprintf('Movie Correlation Matrix %i of %i', frame, size(zmatConcomit, 3)));
            caxis([-1 1])
            hold on
            for ii = 1:length(lobeStartInds)
                plot([0 size(zmatConcomit, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
                plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmatConcomit, 1)+0.5],  'k')
            end
        end
    end
    corrMatShuffle = zeros(size(meanroiTSResids, 1), size(meanroiTSResids, 1), numShuffles);
    zmatShuffle = zeros(size(meanroiTSResids, 1), size(meanroiTSResids, 1), numShuffles);
    for shuffle = 1: numShuffles
        disp(sprintf('Averaging data shuffle %i of %i', shuffle, numShuffles));
        for roi1 = 1:size(meanroiTSResids, 1)
            for roi2 = 1:size(meanroiTSResids, 1)
                randFrame = randi(numFrames, 2, 1);
                corrMatShuffle(roi1, roi2, shuffle) = corr(meanroiTSResids(roi1, :, randFrame(1))', ...
                    meanroiTSResids(roi2, :, randFrame(2))');
                corrMatShuffle(roi2, roi1, shuffle) = corrMatShuffle(roi1, roi2, shuffle);
            end
        end
        zmatShuffle(:,:,shuffle) = atanh(corrMatShuffle(:,:,shuffle));
        if true(plotMatrices)
            figure(3)
            subplot(2,1,1)
            imagesc(mean(corrMatShuffle, 3));
            title(sprintf('Mean Shuffled Movie Matrix'));
            colorbar('EastOutside')
            caxis([-1 1])
            hold on
            for ii = 1:length(lobeStartInds)
                plot([0 size(zmatShuffle, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
                plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmatShuffle, 1)+0.5],  'k')
            end
            subplot(2,1,2)
            imagesc(std(corrMatShuffle, [], 3));
            title(sprintf('SD Shuffled Movie Matrix'));
            colorbar('EastOutside')
            caxis([0 0.5])
            hold on
            for ii = 1:length(lobeStartInds)
                plot([0 size(zmatShuffle, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
                plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmatShuffle, 1)+0.5],  'k')
            end
            
        end
    end
end



%%--------Graph-based Network Analysis-------------

% %% calculate Efficiency metrics
% EffGlob = zeros(size(zmat, 3), 1);
% EffLoc = zeros(size(zmat, 1), size(zmat, 3));
% randMat = zeros(size(corrMat));
% EffGlobRand = zeros(size(EffGlob));
% EffLocRand = zeros(size(EffLoc));
% SW = zeros(size(EffGlob));
% for matrix = 1 :size(corrMat, 3)
%     for correlDir = 1:2
%         thisCorrMat = corrMat(:,:,matrix);
%         if correlDir == 1
%             thisCorrMat(thisCorrMat < 0) = 0;
%         elseif correlDir == 2
%             thisCorrMat(thisCorrMat > 0) = 0;
%             thisCorrMat = -thisCorrMat;
%         end
%         if true(binNet) % calculate efficiency metrics for binary undirected network
%             binCorrMat = zeros(size(thisCorrMat));
%             binCorrMat(find(thisCorrMat >= 0.3)) = 1;
%             EffGlob(matrix, correlDir) = efficiency_bin(binCorrMat);
%             EffLoc(:,matrix, correlDir) = efficiency_bin(binCorrMat, 1);
%             randMat = randmio_und_wei(binCorrMat+1, 5)-1;
%             EffGlobRand(matrix, correlDir) = efficiency_bin(randMat);
%             EffLocRand(:,matrix, correlDir) = efficiency_bin(randMat, 1);
%             SW(matrix, correlDir) = (mean(EffLoc(:,matrix, correlDir))/mean(EffLocRand(:,matrix, correlDir)))/(EffGlob(matrix, correlDir)/EffGlobRand(matrix, correlDir));
%             disp(sprintf('Matrix %i of %i \nGlobal Efficiency = %0.2f \nMean Local Efficiency = %0.2f \nSmall-worldness = %0.2f', matrix, size(zmat, 3), EffGlob(matrix, correlDir), median(EffLoc(:, matrix, correlDir)), SW(matrix, correlDir)));
%             if true(plotMatrices)
%                 figure(1)
%                 imagesc(binCorrMat);
%                 title(sprintf('Matrix %i of %i', matrix, size(zmat, 3)));
%                 caxis([0 1])
%                 colorbar('EastOutside')
%                 hold on
%                 for ii = 1:length(lobeStartInds)
%                     plot([0 size(zmat, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
%                     plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmat, 1)+0.5],  'k')
%                 end
%             end
%         else  % calculate efficiency metrics for weighted undirected network
%             
%             EffGlob(matrix, correlDir) = efficiency_wei(thisCorrMat);
%             EffLoc(:,matrix, correlDir) = efficiency_wei(thisCorrMat, 1);
%             randMat = randmio_und_wei(thisCorrMat,5);
%             EffGlobRand(matrix, correlDir) = efficiency_wei(randMat);
%             EffLocRand(:,matrix, correlDir) = efficiency_wei(randMat, 1);
%             SW(matrix, correlDir) = (mean(EffLoc(:,matrix, correlDir))/mean(EffLocRand(:,matrix, correlDir)))/(EffGlob(matrix, correlDir)/EffGlobRand(matrix, correlDir));
%             disp(sprintf('Matrix %i of %i \nGlobal Efficiency = %0.2f \nMean Local Efficiency = %0.2f \nSmall-worldness = %0.2f', matrix, size(zmat, 3), EffGlob(matrix, correlDir), median(EffLoc(:, matrix, correlDir)), SW(matrix, correlDir)));
%             if true(plotMatrices)
%                 figure(1)
%                 imagesc(thisCorrMat);
%                 title(sprintf('Data Matrix %i of %i', matrix, size(zmat, 3)));
%                 caxis([0 1])
%                 colorbar('EastOutside')
%                 hold on
%                 for ii = 1:length(lobeStartInds)
%                     plot([0 size(zmat, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
%                     plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmat, 1)+0.5],  'k')
%                 end
%             end
%         end
%     end
% end

% %% plot average and std for correlation matrices
% if true(plotAvStdCorrMat)
%     figure(2)
%     subplot(2,1,1)
%     imagesc(mean(corrMat, 3));
%     caxis([-1 1])
%     colorbar('EastOutside')
%     hold on
%     for ii = 1:length(lobeStartInds)
%         plot([0 size(zmat, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
%         plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmat, 1)+0.5],  'k')
%     end
%     title('Average correlation over 10 epochs')
%     subplot(2,1,2)
%     imagesc(std(corrMat, [], 3));
%     caxis([0 0.5])
%     colorbar('EastOutside')
%     hold on
%     for ii = 1:length(lobeStartInds)
%         plot([0 size(zmat, 1)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k')
%         plot([lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], [0 size(zmat, 1)+0.5],  'k')
%     end
%     title('SD correlation over 10 epochs')
% end


% %% plot Efficiency metrics
% if true(plotNetParams)
%     figure(3)
%     subplot(3,1,1)
%     plot(EffGlob);
%     xaxis([0.5 size(EffLoc, 2)+0.5]);
%     title('Global Efficiency')
%     subplot(3,1,2)
%     plot(SW);
%     xaxis([0.5 length(SW)+0.5]);
%     title('Small-worldness')
%     subplot(3,1,3)
%     imagesc(EffLoc);
%     caxis([0 0.5])
%     hold on
%     for ii = 1:length(lobeStartInds)
%         plot([0 size(zmat, 3)+0.5], [lobeStartInds(ii)-0.5 lobeStartInds(ii)-0.5], 'k');
%     end
%     title('Local Efficiency');
% end
