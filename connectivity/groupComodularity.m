function modularity = groupComodularity(corrMat, numSamps, figNum)

% for each subject calculate modularity using louvain method and resultant comodularity matrix
modularity.Q = zeros(size(corrMat, 3), numSamps);
for subj=1:size(corrMat,3)
    disp(sprintf('Processing subject %i',subj))
    thisMat=corrMat(:,:,subj);
    coModSubj = zeros(size(corrMat, 1), size(corrMat, 1), numSamps);
    Ci = zeros(size(corrMat, 1), numSamps);
    % calculate modularity for each sample
    for ii = 1:numSamps
        [Ci(:,ii), modularity.Q(subj,ii)]= modularity_louvain_und_sign(thisMat, 'gja');
        for nodeI=1:size(Ci,1)
            for nodeJ=1:size(Ci,1)
                if Ci(nodeI, ii)==Ci(nodeJ, ii)
                    coModSubj(nodeI,nodeJ,ii) = 1;
                end
            end
        end
    end
    % calculate mean comodularity for each subject
    modularity.meanCoModSubj(:,:,subj) = mean(coModSubj, 3);
end 
modularity.meanCoMod = mean(modularity.meanCoModSubj, 3);   

% find mean comodularity for the group then find modules for this
allCoModG = zeros(size(corrMat, 1), size(corrMat, 2), numSamps);
for ii = 1:numSamps
    [thisCiG, ~]=modularity_louvain_und(modularity.meanCoMod);
    for nodeI=1:length(thisCiG)
            for nodeJ=1:length(thisCiG)
                if thisCiG(nodeI)==thisCiG(nodeJ)
                    allCoModG(nodeI,nodeJ,ii) = 1;
                end
            end
     end
end
% calculate mean comodularity and binarise
modularity.coModG = mean(allCoModG, 3);
binCoModG = zeros(size(modularity.coModG));
binCoModG(modularity.coModG >= 0.5) = 1;

% calculate unique Ci
modularity.CiNewG = zeros(size(corrMat, 1), 1);
nodeMod = 1;
thisNode = 1;
while length(find(modularity.CiNewG)) < length(modularity.CiNewG)
    thisModInds = find(binCoModG(:,thisNode) == 1);
    modularity.CiNewG(thisModInds) = nodeMod;
    thisNode = min(find(modularity.CiNewG == 0));
    nodeMod = nodeMod + 1;
end

% relabel comodularity matrix
for nodeI=1:size(modularity.coModG,1)
    for nodeJ=1:size(modularity.coModG,2)
        if modularity.CiNewG(nodeI)==modularity.CiNewG(nodeJ)
            modularity.coModG(nodeI,nodeJ) = modularity.CiNewG(nodeI);
        end
    end
end

figure(figNum)
subplot(3,1,1)
imagesc(mean(corrMat, 3))
title('Mean Subject Connectivity')
caxis([-0.3 0.5])
axis off
subplot(3,1,2)
imagesc(modularity.meanCoMod)
title('Mean Subject Comodularity')
caxis([0 1])
axis off
subplot(3,1,3)
imagesc(modularity.coModG)
title('Group Comodularity')
colormap jet
axis off
