clear all
%close all

%--------------------------------------------%
%_____________PARAMETERS TO SET______________%

funcDataType = 'RST';
mistimedMovie = 0;
numShuffles = 100;
dataLength = 40;
framesToSkip = 40;
demeanData = 0;
plotMatrices = 1;
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
lobeStartInds = [];
if funcDataType == 'RST'
    directory = 'RS';
elseif funcDataType == 'MOV'
    directory = 'MOVIE';
end

disp('reading ROIs')
rois = MRIread([directory '/all_reg_juelich_to_ref.nii.gz']);
roiVol = rois.vol;
clear rois;

roisToUse = [102,80:2:89, 0:2:5, 103,81:2:89, 1:2:5] + 1;
roiVol = roiVol(:,:,:,roisToUse);
numRois = length(roisToUse);     

%% calculate mean timeseries for each ROI for RS data
% setup framesize and frequency of sampling
numFrames = ceil((size(funcData, 4)-dataLength)/framesToSkip);
meanroiTS = zeros(numRois, dataLength, numFrames);
meanroiTSResids = zeros(size(meanroiTS));
frame = 1;
for dataStart = 1:framesToSkip:size(funcData, 4)-dataLength
    disp(sprintf('Calculating mean timeseries for frame %i of %i', frame, numFrames));
    dataEnd = (dataStart-1)+dataLength;
    %calculate mean timecourse for each ROI
    for roi = 1:numRois
        dataToAnalyse = funcData(:,:,:,dataStart:dataEnd);
        for vol = 1:size(dataToAnalyse, 4)
           thisVolWeighted = dataToAnalyse(:,:,:,vol) .* roiVol(:,:,:,roi);
           weightedMean(vol) = mean(mean(mean(thisVolWeighted))) / mean(mean(mean(roiVol(:,:,:,roi))));
        end
        meanroiTS(roi,:,frame) = weightedMean;
    end
    % demean data if required and calculate Correlation and Z matrices
    if true(demeanData)
        commonSignal = mean(squeeze(meanroiTS(:,:,frame)), 1)';
        for roi = 1:numRois
            Y = squeeze(meanroiTS(roi,:,frame))';
            [B, BINT, R] = regress(Y, [commonSignal ones(size(commonSignal))]);
            meanroiTSResids(roi,:, frame) = R;
        end
    else
        meanroiTSResids = meanroiTS;
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
            imagesc(corrMatConcomit(:,:,frame));
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
