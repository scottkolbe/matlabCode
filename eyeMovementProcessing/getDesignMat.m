function saccparams = getDesignMat(subject)

cd /Users/kolbes/Work/data/ARC_OM_data;

saccparams = struct;
TR = 2.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import trigger times from text file.

%% Initialize variables.
filename = ['eye_movement_files/' subject '/trigger_times.txt'];

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
triggerTimes = zeros(size(raw, 1), 1);
for ii = 1:size(raw, 1)
    saccparams.all.triggerTimes(ii) = raw{ii,1};
end

%% Clear temporary variables
clearvars filename formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import target times and sort as either saccade target or cue


%% Initialize variables.
filename = ['eye_movement_files/' subject '/all_targets.txt'];

delimiter = {'\t',' '};

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
%	column4: text (%s)
%   column5: text (%s)
%	column6: text (%s)
%   column7: text (%s)
%	column8: double (%f)
%   column9: double (%f)
%	column10: text (%s)
%   column11: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%f%s%s%s%s%f%f%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
alltargets = dataset(dataArray{1:end-1}, 'VarNames', {'MSG','VarName2','VarName3','VarName4','VarName5','TARGET_POS','TARG1512384','VarName8','VarName9','VarName10','VarName11'});


validTrial = 1;
nexTrialValid = 1;
for ii = 1:size(alltargets, 1) - 2
    
    thisTargetTime = alltargets{ii,2};
    thisTargetType = alltargets{ii, 7};
    
    nextTargetType = alltargets{ii+1, 7};
    nextnextTargetType = alltargets{ii+2, 7};
    
    if nexTrialValid ~= 0 
        if strcmp(thisTargetType , 'TARG1(512,384)')
            
            if ~strcmp(thisTargetType, nextTargetType)
                saccparams.all.cueOnsetTime(validTrial) = thisTargetTime;
                newTargetType{ii} = 'cue';

            elseif strcmp(thisTargetType, nextTargetType)
                if ~strcmp(thisTargetType, nextnextTargetType)
                    newTargetType{ii} = 'endFix';
                    nexTrialValid = 1;
                elseif strcmp(thisTargetType, nextnextTargetType)
                    newTargetType{ii} = 'endFix';
                    nextTrialValid = 0;
                end
            end
            
         elseif strcmp(thisTargetType, 'TARG1')
                
         targetOnsetTime(validTrial) = thisTargetTime;
         newTargetType{ii} = 'trial';
         validTrial = validTrial + 1;
         nexTrialValid = 1;
         
         end
        
    end
end

targetOnsetTime(192) = alltargets{end-1, 2};
saccparams.all.targetDelays = targetOnsetTime - saccparams.all.cueOnsetTime;
 
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import data from spreadsheet

filename = ['eye_movement_xls/' subject '.xlsx'];

%% Import the data
[~, ~, raw] = xlsread(filename);
raw = raw(6:197,1:70);
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
saccparams.all.TrialDir = data(:,2);
saccparams.all.errorType = cellVectors(:,2);
saccparams.all.timeToCorrect = data(:,3);
saccparams.all.targOnsetTime = data(:,4);
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
saccparams.all.PSerrorType = cellVectors(:,3);
saccparams.all.ASerrorType = cellVectors(:,4);

%PS Parameters
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
%% Find start times of each fMRI run and normalise onset times

triggerIntervals = triggerTimes(2:end)-triggerTimes(1:end-1);
[triggerSort, triggerSortInds] = sort(triggerIntervals, 1, 'descend');
MRIstartInds = triggerSortInds(1:3)+1;
MRIstartTimes = sort([triggerTimes(1); triggerTimes(MRIstartInds)]);
MRIstartTimesStd = (MRIstartTimes - triggerTimes(1))/1000;

run1Inds = find(saccparams.all.targOnsetTime < MRIstartTimesStd(2));
run2Inds = intersect(find(saccparams.all.targOnsetTime > MRIstartTimesStd(2)), find(saccparams.all.targOnsetTime < MRIstartTimesStd(3)));
run3Inds = intersect(find(saccparams.all.targOnsetTime > MRIstartTimesStd(3)), find(saccparams.all.targOnsetTime < MRIstartTimesStd(4)));
run4Inds = find(saccparams.all.targOnsetTime > MRIstartTimesStd(4));

saccparams.all.targOnsetTimeStd(run1Inds) =  saccparams.all.targOnsetTime(run1Inds);
saccparams.all.targOnsetTimeStd(run2Inds) =  saccparams.all.targOnsetTime(run2Inds) - MRIstartTimesStd(2);
saccparams.all.targOnsetTimeStd(run3Inds) =  saccparams.all.targOnsetTime(run3Inds) - MRIstartTimesStd(3);
saccparams.all.targOnsetTimeStd(run4Inds) =  saccparams.all.targOnsetTime(run4Inds) - MRIstartTimesStd(4);
saccparams.all.targOnsetTimeStd = saccparams.all.targOnsetTimeStd';

saccparams.all.targOnsetTimeMRIVols = floor(saccparams.all.targOnsetTimeStd ./ TR);

