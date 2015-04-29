%% this script will read in multiple behavioural scoring files and analyse using
%% analyseBehav then produce plots with associated stats for group comparisons

%% To do:
% 1) get data for each mouse and sort based on animal, phase and day
% 2) calculate total duration and total number of bouts for each behavior
% for each animal
% 3) analyse to create an ANOVA plot for each behaviour after inputing the
% group vector (WT/NL3, SOC/ISO)

%% longer term:
% 4) look at order of behaviours using either time histograms or network
% analysis
% 5) look coincidence with USVs

clear all;

directory = pwd; %
allFiles = dir(directory);
data = cell(1);

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