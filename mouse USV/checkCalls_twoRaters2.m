function [templatelabels] = checkCalls_twoRaters2(starttime, label, rater, onsetError) 

%% sort starttimes
[sortedCalls, sortedCallInds] = sort(starttime);

%% align rater index with calls
templatelabels = cell(max([length(callTimes1) length(callTimes2)]), 5);
sortedRater = rater(sortedCallInds);
actualCallInds = zeros(length(sortedCalls), 1);

actualCall = 1;
call = 1;
while call < length(sortedRater)
    thisRater = sortedRater(call);
    nextRater = sortedRater(call+1);
    if thisRater ~= nextRater
        if sortedCalls(call+1) - sortedCalls(call) < onsetError
            actualCallInds(call) = actualCall;
            actualCallInds(call+1) = actualCall;
            templatelabels{actualCall,1} = actualCall;
            if thisRater == 0
                templatelabels{actualCall,2} = label{call};
                templatelabels{actualCall,3} = sortedCalls(call);
                templatelabels{actualCall,4} = label{call+1};
                templatelabels{actualCall,5} = sortedCalls(call+1);
            elseif thisRater == 1
                templatelabels{actualCall,4} = label{call};
                templatelabels{actualCall,5} = sortedCalls(call);
                templatelabels{actualCall,2} = label{call+1};
                templatelabels{actualCall,3} = sortedCalls(call+1);
            end
            actualCall = actualCall + 1;
            call = call + 2;
        else
            templatelabels{actualCall,1} = actualCall;
            if thisRater == 0
                templatelabels{actualCall,2} = label{call};
                templatelabels{actualCall,3} = sortedCalls(call);
                
            elseif thisRater == 1
                templatelabels{actualCall,4} = label{call};
                templatelabels{actualCall,5} = sortedCalls(call);
                
            end
            actualCallInds(call) = actualCall;
            actualCall = actualCall+1;
            call = call + 1;
        end
    elseif thisRater == nextRater
        templatelabels{actualCall,1} = actualCall;
        if thisRater == 0
            templatelabels{actualCall,2} = label{call};
            templatelabels{actualCall,3} = sortedCalls(call);
            
        elseif thisRater == 1
            templatelabels{actualCall,4} = label{call};
            templatelabels{actualCall,5} = sortedCalls(call);
            
        end
        actualCallInds(call) = actualCall;
        actualCall = actualCall+1;
        call = call + 1;
    end
end

for ii = 1:size(templatelabels, 1)
    if isempty(templatelabels{ii,2})
        templatelabels{ii,2} = 'missed';
    elseif isempty(templatelabels{ii,4})    
        templatelabels{ii,4} = 'missed';
    end
end

uniqClassifications = unique(label);
uniqClassifications{15,1} = 'missed';

incorrectMat = zeros(length(uniqClassifications), length(uniqClassifications));
incorrectTrials = [];
ii = 1;
for call = 1:size(templatelabels, 1)
    if ~strcmp(templatelabels{call,2}, templatelabels{call,4})
        incorrectTrials(ii) = templatelabels{call,1};
        for templateclass = 1:size(incorrectMat, 1)
            for comparatorclass = 1:size(incorrectMat, 2)
                if  strcmp(templatelabels{call,2}, uniqClassifications{templateclass}) && strcmp(templatelabels{call,4}, uniqClassifications{comparatorclass})
                    incorrectMat(templateclass, comparatorclass) = incorrectMat(templateclass, comparatorclass) + 1;
                end
            end
        end
        ii = ii + 1;
    end
end

figure(1)
imagesc(incorrectMat);
caxis([0 75])
ylabel('Rater 0 Classification')
xlabel('Rater 1 Classification')
set(gca,'YTick', [1:1:15],'XTick', [1:1:15]);   
set(gca,'YTickLabel',{uniqClassifications{1},uniqClassifications{2},uniqClassifications{3},uniqClassifications{4},...
    uniqClassifications{5},uniqClassifications{6},uniqClassifications{7},uniqClassifications{8},...
    uniqClassifications{9},uniqClassifications{10},uniqClassifications{11},uniqClassifications{12},uniqClassifications{13},uniqClassifications{14},uniqClassifications{15}},... 
    'XTickLabel',{uniqClassifications{1},uniqClassifications{2},uniqClassifications{3},uniqClassifications{4},...
    uniqClassifications{5},uniqClassifications{6},uniqClassifications{7},uniqClassifications{8},...
    uniqClassifications{9},uniqClassifications{10},uniqClassifications{11},uniqClassifications{12},uniqClassifications{13},uniqClassifications{14},uniqClassifications{15}});

