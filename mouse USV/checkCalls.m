function callComparison = checkCalls(autoCallTimes, manCallTimes, onsetErrorAllowed, classifications, plotem) 

if isempty(classifications)
    classifications = ones(size(manCallTimes, 1), 1);
end

if size(manCallTimes, 2) < 2
    manCallTimes = [manCallTimes ones(size(manCallTimes, 1), 1)];
end

if size(autoCallTimes, 2) < 2
    autoCallTimes = [autoCallTimes ones(size(autoCallTimes, 1), 1)];
end

% remove squeaks from autowhiso
squeakTimes(:,1) = manCallTimes(find(classifications == 11), 1);
squeakTimes(:,2) = manCallTimes(find(classifications == 11), 2);
if size(squeakTimes, 1) > 0   
    for searchOnset = 1:size(autoCallTimes, 2)
        for testOnset = 1:size(squeakTimes, 2)
            if autoCallTimes(1,searchOnset) >= squeakTimes(testOnset, 1)
                if autoCallTimes(searchOnset, 1) <= squeakTimes(testOnset, 2)
                    autoCallTimes(searchOnset, :) = NaN;
                end
            end
        end
    end
end

autoCallTimesonsets = autoCallTimes(:,1);
autoCallTimesoffsets = autoCallTimes(:,2);
autoCallTimesclean(:,1) = autoCallTimesonsets(find(~isnan(autoCallTimesonsets)));
autoCallTimesclean(:,2) = autoCallTimesoffsets(find(~isnan(autoCallTimesoffsets)));

% remove squeaks from manualwhiso
manCallTimesonsets = manCallTimes(:,1);
manCallTimesoffsets = manCallTimes(:,2);
manCallTimesclean(:,1) = manCallTimesonsets(find(classifications < 11));
manCallTimesclean(:,2) = manCallTimesoffsets(find(classifications < 11));

callComparison.classificationsclean = classifications(find(classifications < 11));

% initialise data structure
callComparison.onsets.auto = autoCallTimesclean(:,1);
callComparison.onsets.man = manCallTimesclean(:,1);
callComparison.durations.auto = autoCallTimesclean(:,2)-autoCallTimesclean(:,1);
callComparison.durations.man = manCallTimesclean(:,2)-manCallTimesclean(:,1);

% make a matrix of min and max onsets to search 
% coaligned onset times for both manual and for auto 

% first search manual onsets to identify TPs and FNs
callComparison.onsets.toSearch.man = zeros(size(callComparison.onsets.man,1), 2);
callComparison.onsets.toSearch.man(:,1) =  callComparison.onsets.man - onsetErrorAllowed;
callComparison.onsets.toSearch.man(:,2) =  callComparison.onsets.man + onsetErrorAllowed;

callComparison.onsets.manSearched = zeros(size(callComparison.onsets.man));
callComparison.onsets.manSearchedInd = zeros(size(callComparison.onsets.man));

for searchedOnset = 1:length(callComparison.onsets.man)
    for testedOnset = 1:length(callComparison.onsets.auto)
        if callComparison.onsets.auto(testedOnset) >= callComparison.onsets.toSearch.man(searchedOnset,1)
            if callComparison.onsets.auto(testedOnset) <= callComparison.onsets.toSearch.man(searchedOnset,2)
                   callComparison.onsets.manSearched(searchedOnset) = 1;
                   callComparison.onsets.manSearchedInd(searchedOnset) = testedOnset;
            end
        end
    end
end

% next search auto onsets to identify FPs
callComparison.onsets.toSearch.auto = zeros(size(callComparison.onsets.auto,1), 2);
callComparison.onsets.toSearch.auto(:,1) =  callComparison.onsets.auto - onsetErrorAllowed;
callComparison.onsets.toSearch.auto(:,2) =  callComparison.onsets.auto + onsetErrorAllowed;

callComparison.onsets.autoSearched = zeros(size(callComparison.onsets.auto));
callComparison.onsets.autoSearchedInd = zeros(size(callComparison.onsets.auto));

for searchedOnset = 1:length(callComparison.onsets.auto)
    for testedOnset = 1:length(callComparison.onsets.man)
        if callComparison.onsets.man(testedOnset) >= callComparison.onsets.toSearch.auto(searchedOnset,1)
            if callComparison.onsets.man(testedOnset) <= callComparison.onsets.toSearch.auto(searchedOnset,2)
                   callComparison.onsets.autoSearched(searchedOnset) = 1;
                   callComparison.onsets.autoSearchedInd(searchedOnset) = testedOnset;
            end
        end
    end
end


% now find numbers of TPs, FNs and FPs
manSearchSpace = 1:length(callComparison.onsets.man);
autoSearchSpace = 1:length(callComparison.onsets.auto);

callComparison.detection.TP.man = find(callComparison.onsets.manSearchedInd);
callComparison.detection.TP.auto = find(callComparison.onsets.autoSearched);
callComparison.detection.FN.man = find(callComparison.onsets.manSearched == 0);
callComparison.detection.FP.auto = find(callComparison.onsets.autoSearched == 0);

callComparison.detection.numTP.man = length(callComparison.detection.TP.man);
callComparison.detection.numTP.auto = length(callComparison.detection.TP.auto);
callComparison.detection.numFN.man = length(callComparison.detection.FN.man);
callComparison.detection.numFP.auto = length(callComparison.detection.FP.auto);

if callComparison.detection.numTP.man ~= callComparison.detection.numTP.auto
    sprintf('There is an error because the number of TPs for man and auto are different.\n Please Check!\n');
end

% check durations for FN and FP in manual data to see if simple or complex calls are being
% incorrectly detected
callComparison.detection.TPdurations.man = callComparison.durations.man(callComparison.detection.TP.man);
callComparison.detection.FNdurations.man = callComparison.durations.man(callComparison.detection.FN.man);

% check durations in automatically detected data to see if durations match
% with manual data and the durations of FPs
callComparison.detection.TPdurations.auto = callComparison.durations.auto(callComparison.detection.TP.auto);
callComparison.detection.FPdurations.auto = callComparison.durations.auto(callComparison.detection.FP.auto);

% plot a histogram of durations for FNs and FPs
if plotem
    figure(1)
    subplot(3,2,1),
    hist(callComparison.detection.TPdurations.man, 100);
    title('Correctly detected');
    xlim([0 0.3]);
    legend(sprintf('Total TPs: %i', callComparison.detection.numTP.man), 'Location', 'NorthEast');
    xlabel('Duration (s)');
    subplot(3,2,2),
    hist(callComparison.classificationsclean(callComparison.detection.TP.man));
    title('Correctly detected');
    xlim([0 10]);
    xlabel('Classification');
    subplot(3,2,3),
    hist(callComparison.detection.FNdurations.man, 100);
    title('Failed to detect');
    xlim([0 0.3]);
    legend(sprintf('Total FNs: %i', callComparison.detection.numFN.man), 'Location', 'NorthEast');
    xlabel('Duration (s)');
    subplot(3,2,4),
    hist(callComparison.classificationsclean(callComparison.detection.FN.man));
    title('Failed to detect');
    xlim([0 10]);
    xlabel('Classification');
    subplot(3,2,5),
    hist(callComparison.detection.FPdurations.auto, 100);
    title('Detected where not present');
    xlim([0 0.3]);
    legend(sprintf('Total FPs: %i', callComparison.detection.numFP.auto), 'Location', 'NorthEast');
    xlabel('Duration (s)');
    subplot(3,2,6),
    plot(callComparison.durations.man(callComparison.detection.TP.man), ...
        callComparison.durations.auto(callComparison.detection.TP.auto),'o','MarkerSize',4);
    title('Comparison of durations for correctly detected calls')
    xlabel('Manually defined call duration (sec)')
    ylabel('Automatically detected call duration (sec)')
    
    % plot false positive calls to check
    if plotFPs(true)
        figure(2)
        for call = 1:callComparison.detection.numFP.auto
            imagesc(flipud(autoCalls{callComparison.detection.FP.auto(call)}));
            title(sprintf('Falsely detected call: number %i', callComparison.detection.FP.auto(call)));
            axis off
            pause
        end
    end
end

disp(sprintf('Total TPs: %i', callComparison.detection.numTP.man));
disp(sprintf('Total FNs: %i', callComparison.detection.numFN.man));
disp(sprintf('Total FPs: %i', callComparison.detection.numFP.auto));
