function [templatelabels, incorrectMat] = checkCalls_twoRaters(starttime, label, rater, onsetError) 


%% select onset times for each rater
rater1 = 0;
rater2 = 1;
callTimes1 = starttime(rater == rater1);
callTimes2 = starttime(rater == rater2);
label1 = cell(length(callTimes1), 1);
label2 = cell(length(callTimes2), 1);

ii = 1;
jj = 1;
for thisLabel = 1:length(label)
    if rater(thisLabel) == rater1
        label1{ii} = label{thisLabel};
        ii = ii+1;
     elseif rater(thisLabel) == rater2
         label2{jj} = label{thisLabel};
         jj = jj+1;
    end
end

uniqClassifications = unique(label);


%% Rater 1 vs Rater 2: Rater 1 is template to search
onsetsToSearch = zeros(2,length(callTimes1));
onsetsToSearch(1,:) =  callTimes1 - onsetError;
onsetsToSearch(2,:) =  callTimes1 + onsetError;

comparatorlabels = nan(length(callTimes1), 1);
templatelabels = cell(length(callTimes1), 5);

for searchedOnset = 1:length(callTimes1)
    for testedOnset = 1:length(callTimes2)
        templatelabels{searchedOnset,1} = searchedOnset;
        templatelabels{searchedOnset,2} = label1{searchedOnset};
        templatelabels{searchedOnset,3} = callTimes1(searchedOnset);
        if (callTimes2(testedOnset) >= onsetsToSearch(1,searchedOnset)) && ...
                (callTimes2(testedOnset) <= onsetsToSearch(2,searchedOnset))
            comparatorlabels(searchedOnset) = testedOnset;
            templatelabels{searchedOnset,4} = label2{testedOnset};
            templatelabels{searchedOnset,5} = callTimes2(testedOnset);      
        end
    end
end

incorrectMat = zeros(length(uniqClassifications), length(uniqClassifications));
incorrectTrials = [];
ii = 1;
for call = 1:size(templatelabels, 1)
    if ~strcmp(templatelabels{call,2}, templatelabels{call,4})
        incorrectTrials(ii) = templatelabels{call,1};
        for templateclass = 1:length(uniqClassifications)
            for comparatorclass = 1:length(uniqClassifications)
                if strcmp(templatelabels{call,2}, uniqClassifications{templateclass}) && strcmp(templatelabels{call,4}, uniqClassifications{comparatorclass})
                    incorrectMat(templateclass, comparatorclass) = incorrectMat(templateclass, comparatorclass) + 1;
                end
            end
        end
        ii = ii + 1;
    end
end

figure(1)
imagesc(incorrectMat);
caxis([0 70])
ylabel('EB Classification')
xlabel('AE Classification')
set(gca,'YTick', [1:1:14],'XTick', [1:1:14]);   
set(gca,'YTickLabel',{uniqClassifications{1},uniqClassifications{2},uniqClassifications{3},uniqClassifications{4},...
    uniqClassifications{5},uniqClassifications{6},uniqClassifications{7},uniqClassifications{8},...
    uniqClassifications{9},uniqClassifications{10},uniqClassifications{11},uniqClassifications{12},uniqClassifications{13},uniqClassifications{14}},... 
    'XTickLabel',{uniqClassifications{1},uniqClassifications{2},uniqClassifications{3},uniqClassifications{4},...
    uniqClassifications{5},uniqClassifications{6},uniqClassifications{7},uniqClassifications{8},...
    uniqClassifications{9},uniqClassifications{10},uniqClassifications{11},uniqClassifications{12},uniqClassifications{13},uniqClassifications{14}});

