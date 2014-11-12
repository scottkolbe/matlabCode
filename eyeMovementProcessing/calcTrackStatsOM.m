clear all 
close all


workDir = '/Volumes/edward/projects/pMelb0036/om_2013/data2/';

dirs = dir(workDir);

% find control and patient directory names within the working directory
currDir = 1;
for toCheck = 1:size(dirs,1)
    
    item = dirs(toCheck).name;
    
    % is it a control or a patient?
    if item(1) == '0'
                subjDirs{currDir} = item;
                currDir = currDir +1;
            
            
    end
end

roiCombinations = cell(2,3);
roiCombinations{1,1} = 's_colliculcus_L.mif';
roiCombinations{1,2} = 'reg_wLeft_Parietal.nii';
roiCombinations{1,3} = 'Left_SC2Par_ex.tck';

roiCombinations{2,1} = 's_colliculcus_R.mif';
roiCombinations{2,2} = 'reg_wRight_Parietal.nii';
roiCombinations{2,3} = 'Right_SC2Par_ex.tck';

paramToTest = 'FA';

for subj = 1 :17 %: length(subjDirs) %loop over all control subjects
    
        for tract = 1:2
            
            disp(sprintf('Cropping tracks for subject %s: %s to %s', ...
                subjDirs{subj}, roiCombinations{tract,1}, roiCombinations{tract,2}));
            
            trackFile = [workDir subjDirs{subj} '/1/tractography/' roiCombinations{tract,3}];
            
            paramImg = [workDir subjDirs{subj} '/1/mrtrix/fa.mif']; % need this here for the mrtrix transformation
            
            roi1Img = [workDir subjDirs{subj} '/1/tractography/' roiCombinations{tract,1}];
                
            roi2Img = [workDir subjDirs{subj} '/1/tractography/' roiCombinations{tract,2}];
            
            numResamp = 100; % number of lengthwise samples to generate
            
            plotem = 0; % plot the tracks
            
            fignum = 1;
            
            % crop and normalise tracks
            tracks = cropTracks(trackFile, paramImg, roi1Img, roi2Img, numResamp, plotem, fignum);

            
            %repeat for various parameter images
            disp(sprintf('Sampling parameter images for subject %s: %s to %s', ...
                subjDirs{subj}, roiCombinations{tract,1}, roiCombinations{tract,2}));
             
            method = 'interp';
            plotem = 0; 
             
            fignum = 2;
            
            switch(paramToTest)
                case('FA') 
                    param = read_mrtrix([workDir subjDirs{subj} '/1/mrtrix/fa.mif']);
                    data = param.data;
                case('AD')
                    param = read_mrtrix([workDir subjDirs{subj} '/1/mrtrix/eigs.mif']);
                    data = param.data(:,:,:,1);
                case('RD')
                    param = read_mrtrix([workDir subjDirs{subj} '/1/mrtrix/eigs.mif']);
                    data = (param.data(:,:,:,2) + param.data(:,:,:,3)) /2;
                case('MD')
                    param = read_mrtrix([workDir subjDirs{subj} '/1/mrtrix/eigs.mif']);
                    data = (param.data(:,:,:,1) + param.data(:,:,:,2) + param.data(:,:,:,3)) /3;
            end
            
            meanTrackParam(:,subj,tract) = lengthWiseTrackAnalysis(tracks, data, paramToTest, method, plotem, fignum);
           
            
        end
 
        
end
meanAllParam = squeeze(mean(meanTrackParam, 2));
seAllParam = squeeze(std(meanTrackParam, [], 2)) ./ sqrt(size(meanTrackParam, 2));
figure
hold on
errorbar(meanAllParam(:,1), seAllParam(:,1));
errorbar(meanAllParam(:,2), seAllParam(:,2), 'r');
legend('Left', 'Right');
xlabel('Sample Point');
ylabel(paramToTest)
hold off