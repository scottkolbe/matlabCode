rootDir = '/Volumes/edward/projects/pMelb0036/GWAS/RHH_data/combined/1.5.97';
cd(rootDir);

brainVols = nan*ones(size(allScans));
lesionVols = nan*ones(size(allScans));
scalingFactors = nan*ones(size(allScans));
ageAtScan = nan*ones(size(allScans));

ii = 1;

for subj = 1:length(PSSID)-2
    subjDir = PSSID{subj};
    
    cd(subjDir)
    allDirs = dir(pwd);
    brainVolsSubj = [];
    lesionVolsSubj = [];
    scalingFactorsSubj = [];
    thisScanId = cell(1,1);
    jj = 1;
    for thisDir = 1:size(allDirs, 1)
        if ~strcmp(allDirs(thisDir).name, '.') && ~strcmp(allDirs(thisDir).name, '..') 
            cd(allDirs(thisDir).name);
            if exist('brain_volume.txt', 'file') && exist('lesion_volume.txt', 'file') && exist('scaling_factor.txt', 'file')
                disp(allDirs(thisDir).name)
                thisBrainVol = load('brain_volume.txt');
                thisLesionVol = load('lesion_volume.txt');
                thisScalFact = load('scaling_factor.txt');
                
                thisScanId{jj} = allDirs(thisDir).name;
                
                if length(thisBrainVol) == 2
                    brainVolsSubj(jj) = thisBrainVol(2);
                else
                    brainVolsSubj(jj) = NaN;
                end
                if length(thisLesionVol) == 2
                    lesionVolsSubj(jj) = thisLesionVol(2);
                else
                    lesionVolsSubj(jj) = NaN;
                end
                scalingFactorsSubj(jj) = thisScalFact;
                jj = jj + 1;
            end
            cd ..
        end
    end
    
    if ~isempty(brainVolsSubj)
        
        % get study indices for the current subject
        for stud = 1:length(thisScanId)
            PSSIDinds = find(ismember(study_ID,thisScanId{stud}));
            brainVols(subj,stud) = brainVolsSubj(stud);
            lesionVols(subj,stud) = lesionVolsSubj(stud);
            scalingFactors(subj,stud) = scalingFactorsSubj(stud);
            ageAtScan(subj, stud) = scanYear(PSSIDinds) - dob(subj);
        end
        
        
    end

    cd ..
end