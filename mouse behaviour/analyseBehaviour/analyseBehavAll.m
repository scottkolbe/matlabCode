%% this script will read in multiple behavioural scoring files and analyse using
%% analyseBehav then produce plots with associated stats for group comparisons


%% to do:
% 4) look at order of behaviours using either time histograms or network
% analysis
% 5) look coincidence with USVs

clear all;

genoVect = [1 1 0 0 0 1 0 1 1 0 0 0 0 1 0 1 1 1 1 1 0 0 0 0 0 1 0 0 1 1 1 0 1 1 0 0 1]; % 0:WT; 1:NL3
housingVect = [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];% 0:SOC; 1:ISO

allBehav = cell(1);
allBehav{1} = 'snfHeadFace';
allBehav{2} = 'snfBdy';
allBehav{3} = 'snfAGT';
allBehav{4} = 'mnt';
allBehav{5} = 'bitAtt';
allBehav{6} = 'chsStk';
allBehav{7} = 'grmGen';
allBehav{8} = 'grmFceBdy';
allBehav{9} = 'rtlSnk';
allBehav{10} = 'shvl';
allBehav{11} = 'other';


directory = pwd; %
allFiles = dir(directory);
data = cell(1);
names = cell(1);
for ii = 1:length(allFiles)
    if length(allFiles(ii).name) > 5 && ...
            strcmp(allFiles(ii).name(end-2:end), 'mat') && ...
            isempty(strfind(allFiles(ii).name, 'analysed'))
        phase = str2num(allFiles(ii).name(end-4));
        day = str2num(allFiles(ii).name(end-6));
        subj = str2num(allFiles(ii).name(1:end-8));
        data{subj,day,phase} = analyseBehav([directory '/'], allFiles(ii).name, 0, 0);
    end
end



% set up data matrix for ANOVA
subj = 1;
onsetsTable = [];
durationsTable = [];
boutsTable = [];

for ii = 1:size(data,1)
    if ~isempty(data{ii,1,1}) || ~isempty(data{ii,1,2}) || ~isempty(data{ii,2,1}) || ~isempty(data{ii,2,2}) || ~isempty(data{ii,2,3})
        for day = 1:2
            for phase = 1:3
                if ~isempty(data{ii,day,phase})
                    for behav = 1:length(allBehav)
                        if ~isempty(find(strcmp(data{ii,day,phase}.names, allBehav{behav})))
                            behavInd = find(strcmp(data{ii,day,phase}.names, allBehav{behav}));
                            onsetsTable(subj,day,phase,behav) = min(data{ii,day,phase}.onsets{behavInd});
                            durationsTable(subj,day,phase,behav) = sum(data{ii,day,phase}.durations{behavInd});
                            boutsTable(subj,day,phase,behav) = length(find(data{ii,day,phase}.onsets{behavInd}));
                        else
                            onsetsTable(subj,day,phase,behav) = NaN;
                            durationsTable(subj,day,phase,behav) = 0;
                            boutsTable(subj,day,phase,behav) = 0;
                        end
                    end
                else
                    onsetsTable(subj,day,phase,:) = nan(length(allBehav), 1);
                    durationsTable(subj,day,phase,:) = nan(length(allBehav), 1);
                    boutsTable(subj,day,phase,:) = zeros(length(allBehav), 1);
                end
            end
        end
        
        subj = subj + 1;
    end
end

% plot data for two groups

numBehav = 8; %length(allBehav);
for behav = 1:numBehav
    % plot onsets
    figure(1)
    subplot(ceil(numBehav/2),2,behav)
    thisData = squeeze(nanmean(durationsTable(:,:,[1 3],behav), 3));
    boxplot([thisData(:,1);thisData(:,2)], [[zeros(size(thisData, 1), 1); ones(size(thisData, 1), 1)] [genoVect';genoVect'] [housingVect';housingVect']])
    title([allBehav{behav} ' durations'])
     set(gca,'XTick',[1 2 3 4 5 6 7 8],...
        'XTickLabel',{'WT/SOC/EP1','WT/ISO/EP1','NL3/SOC/EP1','NL3/ISO/EP1','WT/SOC/EP2','WT/ISO/EP2','NL3/SOC/EP2','NL3/ISO/EP2'});
    ylabel('Total Duration (s)')
    
    figure(2)
    subplot(ceil(numBehav/2),2,behav)
    thisData = squeeze(nanmean(durationsTable(:,:,[1 3],behav), 2));
    boxplot([thisData(:,1);thisData(:,2)], [[zeros(size(thisData, 1), 1); ones(size(thisData, 1), 1)] [genoVect';genoVect'] [housingVect';housingVect']])
    title([allBehav{behav} ' durations'])
     set(gca,'XTick',[1 2 3 4 5 6 7 8],...
        'XTickLabel',{'WT/SOC/Ph1','WT/ISO/Ph1','NL3/SOC/Ph1','NL3/ISO/Ph1','WT/SOC/Ph3','WT/ISO/Ph3','NL3/SOC/Ph3','NL3/ISO/Ph3'});
     ylabel('Total Duration (s)')
     
    figure(3)
    subplot(ceil(numBehav/2),2,behav)
    thisData = squeeze(nanmean(squeeze(nanmean(durationsTable(:,:,[1 3],behav), 2)),2));
    boxplot(thisData, [genoVect' housingVect'])
    title([allBehav{behav} ' durations'])
     set(gca,'XTick',[1 2 3 4],...
        'XTickLabel',{'WT/SOC','WT/ISO','NL3/SOC','NL3/ISO'});
     ylabel('Total Duration (s)')
    
end


% statistical analysis

allDurations = reshape(durationsTable(:,:,[1 3],:), ... % omit phase 2
    [size(durationsTable, 1) * size(durationsTable, 2) * 2, size(durationsTable, 4)]);

modelMat = [repmat(genoVect', 4,1) ... %geno
    repmat(housingVect',4,1) ... %housing
    repmat([zeros(37,1);ones(37,1)], 2, 1) ... %day
    [zeros(37*2,1);ones(37*2,1)] ... %phase
    repmat([1:37]', 4, 1)]; %subj

for ii = 1:11
    [p,table,stats,terms] = anovan(allDurations(:,ii), ...
        modelMat, ...
        'model', [1 0 0 0 0;0 1 0 0 0; 1 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0], ...
        'random', 5, ...
        'varnames', {'GENO', 'HOUSING', 'EXPOSURE', 'PHASE', 'SUBJ'});
   results(ii).p = p;
   results(ii).table = table;
   results(ii).stats = stats;
   results(ii).terms = terms;
end



% 



