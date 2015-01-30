function [saccparams, ev] = getSaccParams(matFile, triggerFile, targetsFile, xlsFile, study, plotRuns)

% STUDY = 'arc' / 'pmfx' 

%% initialise some variables
saccparams = struct;
ev = struct;
TR = 2.5;
numVols = 110; % a conservative estimate of the number of volumes for the last run

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import gaze data from .mat file
load(matFile);
eyeTimes = convert_data(:, 1);
eyeRes = eyeTimes(2)-eyeTimes(1);
eyeVel = convert_data(:,5);
eyeVel(isnan(eyeVel)) = 0;
eyeVel(eyeVel > 500) = 0;
eyeVel(eyeVel < -500) = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import trigger times from text file.

%% Initialize variables.
filename = triggerFile;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%13s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '',  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Create output variable
saccparams.all.triggerTimes = zeros(size(raw, 1), 1);
for ii = 1:size(raw, 1)
    saccparams.all.triggerTimes(ii) = raw{ii,1};
end

%% Clear temporary variables
clearvars filename formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import target times and sort as either saccade target or cue

%% Initialize variables.
filename = targetsFile;

delimiter = {'\t',',',' ','(',')'};

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: text (%s)
%	column4: text (%s)
%   column5: text (%s)
%	column6: text (%s)
%   column7: text (%s)
%	column8: text (%s)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%s%s%s%s%s%s%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
alltargets = dataset(dataArray{1:end-1}, 'VarNames', {'MSG','VarName2','VarName3','VarName4','VarName5','TARGET_POS','TARG1','VarName8','VarName9','VarName10','VarName11','VarName12'});

validTrial = 1;

for ii = 1:size(alltargets, 1)
    thisTargetTime = alltargets.VarName2(ii);
    thisTargetType = alltargets.VarName10(ii, 1);
    
    if ii == 1
        saccparams.all.cueOnsetTime(validTrial) = thisTargetTime;
        saccparams.all.newTargetType{ii} = 'cueFix';
        
    elseif ii == size(alltargets, 1)
        saccparams.all.newTargetType{ii} = 'endFix';
        
    else
        nextTargetType = alltargets.VarName10(ii+1);
        prevTargetType = alltargets.VarName10(ii-1);
        
        if isnan(thisTargetType) && nextTargetType == 1
            saccparams.all.cueOnsetTime(validTrial) = thisTargetTime;
            saccparams.all.newTargetType{ii} = 'cueFix';
            
        elseif isnan(thisTargetType) && isnan(nextTargetType) && isnan(prevTargetType)
            saccparams.all.newTargetType{ii} = 'nullFix';
            
        elseif isnan(thisTargetType) && isnan(nextTargetType) && prevTargetType == 1
            saccparams.all.newTargetType{ii} = 'endFix';
            
        elseif thisTargetType == 1
            saccparams.all.targetOnsetTime(validTrial) = thisTargetTime;
            saccparams.all.newTargetType{ii} = 'trial';
            validTrial = validTrial + 1;
            
        end
    end
end
saccparams.all.targetOnsetTime = saccparams.all.targetOnsetTime';
saccparams.all.cueOnsetTime = saccparams.all.cueOnsetTime';


saccparams.all.targetDelays = saccparams.all.targetOnsetTime - saccparams.all.cueOnsetTime;
saccparams.all.targetOnsetTime = (saccparams.all.targetOnsetTime - saccparams.all.triggerTimes(1)) /1000;
saccparams.all.cueOnsetTime = (saccparams.all.cueOnsetTime - saccparams.all.triggerTimes(1)) /1000;

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import data from spreadsheet

filename = xlsFile;

%% Import the data
[~, ~, raw] = xlsread(filename,'Sheet1');
if strcmp(study, 'pmfx')
    raw = raw(6:197,[2:45 47:72]);
elseif strcmp(study, 'arc')
    raw = raw(6:197,1:70);
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[2,4,17,18,19]);
raw = raw(:,[1,3,5,6,7,8,9,10,11,12,13,14,15,16,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names

%Overall Parameters
saccparams.all.trialNum = data(:,1);
saccparams.all.trialType = cellVectors(:,1);
saccparams.all.trialDir = data(:,2);
saccparams.all.errorType = cellVectors(:,2);
saccparams.all.timeToCorrect = data(:,3);
saccparams.all.manTargOnsetTime = data(:,4);
saccparams.all.targOnsetEyePos = data(:,5);
saccparams.all.saccOnsetTime = data(:,6);
saccparams.all.saccOnsetEyePos = data(:,7);
saccparams.all.saccEndTime = data(:,8);
saccparams.all.saccEndPos = data(:,9);
saccparams.all.fepEndTime = data(:,10);
saccparams.all.fepEndPos = data(:,11);
saccparams.all.velPeak = data(:,12);
saccparams.all.timeofVelPeak = data(:,13);
saccparams.all.meanVel = data(:,14);

%PS Parameters
saccparams.ps.errorType = cellVectors(:,3);
saccparams.ps.latency = data(:,15);
saccparams.ps.firstsaccAmp = data(:,16);
saccparams.ps.firstsaccGain = data(:,17);
saccparams.ps.FEPamp = data(:,18);
saccparams.ps.FEPgain = data(:,19);
saccparams.ps.firstSaccAbsPosError = data(:,20);
saccparams.ps.fepAbsPosError = data(:,21);
saccparams.ps.meanfirstSaccAbsPosError = data(:,22);
saccparams.ps.meanFEPAbsPosError = data(:,23);
saccparams.ps.firstSaccDuration = data(:,24);
saccparams.ps.peakVel = data(:,25);
saccparams.ps.timeToPeakVel = data(:,26);
saccparams.ps.absMeanVel = data(:,27);
saccparams.ps.peakVelDIVmeanVel = data(:,28);

%AS Parameters
saccparams.as.errorType = cellVectors(:,4);
saccparams.as.latency = data(:,41);
saccparams.as.firstsaccAmp = data(:,42);
saccparams.as.firstsaccGain = data(:,43);
saccparams.as.FEPamp = data(:,44);
saccparams.as.FEPgain = data(:,45);
saccparams.as.firstSaccAbsPosError = data(:,46);
saccparams.as.fepAbsPosError = data(:,47);
saccparams.as.meanfirstSaccAbsPosError = data(:,48);
saccparams.as.meanFEPAbsPosError = data(:,49);
saccparams.as.firstSaccDuration = data(:,50);
saccparams.as.peakVel = data(:,51);
saccparams.as.timeToPeakVel = data(:,52);
saccparams.as.absMeanVel = data(:,53);
saccparams.as.peakVelDIVmeanVel = data(:,54);


%% Clear temporary variables
clearvars data raw cellVectors R;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find start times of each valid fMRI run (>numVols volumes) and normalise onset times
saccparams.all.triggerIntervals = saccparams.all.triggerTimes(2:end)-saccparams.all.triggerTimes(1:end-1);
initialRunTriggers = find(saccparams.all.triggerIntervals > 4*TR*1000+5)+1; % allow +5ms error in trigger timing
finalRunTriggers = [find(saccparams.all.triggerIntervals > 4*TR*1000+5); length(saccparams.all.triggerIntervals)];
discontinuities = sort([initialRunTriggers; finalRunTriggers]);
validRuns = [];
for ii = 1:length(discontinuities)-1
   runTimes(ii) = sum(saccparams.all.triggerIntervals(discontinuities(ii):discontinuities(ii+1)));

if runTimes(ii) >= numVols*TR*1000
       validRuns(ii) = ii;
end
end
validRuns = validRuns(find(validRuns));
disp(sprintf('Found %i valid runs: \n', length(validRuns)));
for run = 1:length(validRuns)
    disp(sprintf('Run %i : %0.3f seconds \n', validRuns(run), runTimes(validRuns(run))));
    MRIstartTimes(run) = saccparams.all.triggerTimes(discontinuities(validRuns(run)));
end

MRIstartTimesStd = (MRIstartTimes - saccparams.all.triggerTimes(1))/1000;

if true(plotRuns)
    figure(1)
    subplot(2,1,1)
    plot(eyeTimes)
    hold on
    for run = 1:length(MRIstartTimes)
        plot([0 length(eyeTimes)], [MRIstartTimes(run) MRIstartTimes(run)], 'r');
    end
    title('Eyelink samples with valid run start times')
    xlabel('Samples')
    ylabel('Time')
    xlim([0 length(eyeTimes)])
    
    subplot(2,1,2)
    plot(saccparams.all.triggerTimes)
    hold on
    for run = 1:length(MRIstartTimes)
        plot([0 length(saccparams.all.triggerTimes)], [MRIstartTimes(run) MRIstartTimes(run)], 'r');
    end
    title('MRI triggers with valid run start times')
    xlabel('Triggers')
    ylabel('Time')
    xlim([0 length(saccparams.all.triggerTimes)])
end

%% Find target onsets

% find target onset indices for correct and error trials
allPsDirErrorInds =[find(strcmp(saccparams.ps.errorType,'Dir')); find(strcmp(saccparams.ps.errorType,'dir')); find(strcmp(saccparams.ps.errorType,'Dirx2'))];
allAsDirErrorInds = [find(strcmp(saccparams.as.errorType,'Dir')); find(strcmp(saccparams.as.errorType, 'dir')); find(strcmp(saccparams.as.errorType,'Dirx2'))];
allPsOtherErrorInds = [find(strcmp(saccparams.ps.errorType,'blink')); find(strcmp(saccparams.ps.errorType,'sigdrop')); ...
    find(strcmp(saccparams.ps.errorType,'unstab')); find(strcmp(saccparams.ps.errorType,'antic'))];
allAsOtherErrorInds = [find(strcmp(saccparams.as.errorType,'blink')); find(strcmp(saccparams.as.errorType,'sigdrop')); ...
    find(strcmp(saccparams.as.errorType,'unstab')); find(strcmp(saccparams.as.errorType,'antic'))];

allErrInds = sort([allPsDirErrorInds; allAsDirErrorInds; allPsOtherErrorInds; allAsOtherErrorInds]);

allPsInds = find(~isnan(saccparams.as.latency));
allAsInds = find(~isnan(saccparams.ps.latency));
allPsPsInds = [];
allAsPsInds = [];
allErrPsInds = [];
allAsAsInds = [];
allPsAsInds = [];
allErrAsInds = [];

for ii = 1:length(allPsInds)
    thisInd = allPsInds(ii);
    if thisInd == 1;
        allPsPsInds(1) = 1;
    else
        prevInd = allPsInds(ii) - 1;
        if ~isempty(find(allPsInds == prevInd))
            allPsPsInds = [allPsPsInds; thisInd];
        elseif ~isempty(find(allAsInds == prevInd));
            allAsPsInds = [allAsPsInds; thisInd];
        elseif ~isempty(find(allErrInds == prevInd));
            allErrPsInds = [allErrPsInds; thisInd];
        end
    end
end

for ii = 1:length(allAsInds)
    thisInd = allAsInds(ii);
    if thisInd == 1;
        allAsAsInds(1) = 1;
    else
        prevInd = allAsInds(ii) - 1;
        if ~isempty(find(allAsInds == prevInd))
            allAsAsInds = [allAsAsInds; thisInd];
        elseif ~isempty(find(allPsInds == prevInd));
            allPsAsInds = [allPsAsInds; thisInd];
        elseif ~isempty(find(allErrInds == prevInd));
            allErrAsInds = [allErrAsInds; thisInd];
        end
    end
end

% find indices for each run
runInds = cell(length(validRuns), 1);
for run = 1:length(validRuns)
    runInds{run} = intersect(find(saccparams.all.targetOnsetTime >= MRIstartTimesStd(run)), find(saccparams.all.targetOnsetTime < MRIstartTimesStd(run)+133*TR));
end

% get Inds for each trial type and eye velocity vector
for run = 1:length(validRuns)
    pspsInds{run} = intersect(allPsPsInds, runInds{run});
    aspsInds{run} = intersect(allAsPsInds, runInds{run});
    errpsInds{run} = intersect(allErrPsInds, runInds{run});
    asasInds{run} = intersect(allAsAsInds, runInds{run});
    psasInds{run} = intersect(allPsAsInds, runInds{run});
    errasInds{run} = intersect(allErrAsInds, runInds{run});
     
    psDirErrorInds{run} = intersect(allPsDirErrorInds, runInds{run});
    asDirErrorInds{run} = intersect(allAsDirErrorInds, runInds{run});
    psOtherErrorInds{run} = intersect(allPsOtherErrorInds, runInds{run});
    asOtherErrorInds{run} = intersect(allAsOtherErrorInds, runInds{run});
    eyeInds{run} = intersect(find(eyeTimes >= MRIstartTimes(run)), find(eyeTimes < (MRIstartTimes(run)+133*TR*1000)));
end
 
% output environment variables in terms of MR timeseries volume for FEAT analysis
for run = 1:length(validRuns)
    ev.pspstargOnsetTime{run} =  saccparams.all.targetOnsetTime(pspsInds{run}) - MRIstartTimesStd(run);
    ev.pspstargOnsetTime{run} =  [ev.pspstargOnsetTime{run} ones(size(ev.pspstargOnsetTime{run}, 1), 1) ones(size(ev.pspstargOnsetTime{run}, 1), 1)];
    ev.aspstargOnsetTime{run} =  saccparams.all.targetOnsetTime(aspsInds{run})- MRIstartTimesStd(run);
    ev.aspstargOnsetTime{run} =  [ev.aspstargOnsetTime{run} ones(size(ev.aspstargOnsetTime{run}, 1), 1) ones(size(ev.aspstargOnsetTime{run}, 1), 1)];
    ev.errpstargOnsetTime{run} =  saccparams.all.targetOnsetTime(errpsInds{run})- MRIstartTimesStd(run);
    ev.errpstargOnsetTime{run} =  [ev.errpstargOnsetTime{run} ones(size(ev.errpstargOnsetTime{run}, 1), 1) ones(size(ev.errpstargOnsetTime{run}, 1), 1)];
  
    ev.asastargOnsetTime{run} =  saccparams.all.targetOnsetTime(asasInds{run})- MRIstartTimesStd(run);
    ev.asastargOnsetTime{run} =  [ev.asastargOnsetTime{run} ones(size(ev.asastargOnsetTime{run}, 1), 1) ones(size(ev.asastargOnsetTime{run}, 1), 1)];
    ev.psastargOnsetTime{run} =  saccparams.all.targetOnsetTime(psasInds{run})- MRIstartTimesStd(run);
    ev.psastargOnsetTime{run} =  [ev.psastargOnsetTime{run} ones(size(ev.psastargOnsetTime{run}, 1), 1) ones(size(ev.psastargOnsetTime{run}, 1), 1)];
    ev.errastargOnsetTime{run} =  saccparams.all.targetOnsetTime(errasInds{run})- MRIstartTimesStd(run);
    ev.errastargOnsetTime{run} =  [ev.errastargOnsetTime{run} ones(size(ev.errastargOnsetTime{run}, 1), 1) ones(size(ev.errastargOnsetTime{run}, 1), 1)];
    
    ev.psDirErrortargOnsetTime{run} =  saccparams.all.targetOnsetTime(psDirErrorInds{run})- MRIstartTimesStd(run);
    ev.psDirErrortargOnsetTime{run} =  [ev.psDirErrortargOnsetTime{run} ones(size(ev.psDirErrortargOnsetTime{run}, 1), 1) ones(size(ev.psDirErrortargOnsetTime{run}, 1), 1)];
    ev.asDirErrortargOnsetTime{run} =  saccparams.all.targetOnsetTime(asDirErrorInds{run})- MRIstartTimesStd(run);
    ev.asDirErrortargOnsetTime{run} =  [ev.asDirErrortargOnsetTime{run} ones(size(ev.asDirErrortargOnsetTime{run}, 1), 1) ones(size(ev.asDirErrortargOnsetTime{run}, 1), 1)];
    ev.psOtherErrortargOnsetTime{run} =  saccparams.all.targetOnsetTime(psOtherErrorInds{run})- MRIstartTimesStd(run);
    ev.psOtherErrortargOnsetTime{run} =  [ev.psOtherErrortargOnsetTime{run} ones(size(ev.psOtherErrortargOnsetTime{run}, 1), 1) ones(size(ev.psOtherErrortargOnsetTime{run}, 1), 1)];
    ev.asOtherErrortargOnsetTime{run} =  saccparams.all.targetOnsetTime(asOtherErrorInds{run})- MRIstartTimesStd(run);
    ev.asOtherErrortargOnsetTime{run} =  [ev.asOtherErrortargOnsetTime{run} ones(size(ev.asOtherErrortargOnsetTime{run}, 1), 1) ones(size(ev.asOtherErrortargOnsetTime{run}, 1), 1)];
    ev.eye{run} = [(eyeTimes(eyeInds{run})-MRIstartTimes(run))/1000 ones(size(eyeInds{run}, 1),1)*eyeRes/1000 eyeVel(eyeInds{run})];
end
