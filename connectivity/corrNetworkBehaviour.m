function [table1, table2] = corrNetworkBehaviour(corrMat, behav1, behav2, numSamps)

% calculate comodularity for each subject and then whole group
% correlat network parameters with behavioural variables

for subj=1:size(corrMat,3)
    thisMat=corrMat(:,:,subj);
    coModSubj = zeros(size(corrMat, 1), size(corrMat, 1), numSamps);
    Ci = zeros(size(corrMat, 1), numSamps);
    % calculate modularity for each sample
    for ii = 1:numSamps
        [Ci, ~]= modularity_louvain_und_sign(thisMat);
        for nodeI=1:length(Ci)
            for nodeJ=1:length(Ci)
                if Ci(nodeI)==Ci(nodeJ)
                    coMod(nodeI,nodeJ,ii) = 1;
                end
            end
        end
    end
    coMod = mean(coMod, 3);
    coMod(coMod < 0.5) = 0;
    coMod(coMod >= 0.5) = 1;
    
    Ci = zeros(size(Ci, 1), 1);
    nodeMod = 1;
    thisNode = 1;
    while length(find(Ci)) < length(Ci)
        thisModInds = find(coMod(:,thisNode) == 1);
        Ci(thisModInds) = nodeMod;
        thisNode = min(find(Ci == 0));
        nodeMod = nodeMod + 1;
    end
    [Spos Sneg vpos vneg] = strengths_und_sign(thisMat);
    strengthPos(:,subj) = (Spos./vpos); 
    strengthNeg(:,subj) = (Sneg./vneg);
    [Ppos Pneg] = participation_coef_sign(thisMat,Ci);
    particPos(:,subj) = Ppos;
    particNeg(:,subj) = Pneg;
    disp(sprintf('Number of modules for subject %i = %i', subj, max(Ci)))
    numMod(subj) = max(Ci); 
end


strengthPosG = mean(strengthPos, 2);
strengthNegG = mean(strengthNeg, 2);
strongNodesPos = find(strengthPosG>mean(strengthPosG)+std(strengthPosG));
strongNodesNeg = find(strengthNegG>mean(strengthNegG)+std(strengthNegG));


figure(1)
subplot(2,2,1)
imagesc(strengthPos')
caxis([0 0.05])
subplot(2,2,2)
imagesc(strengthNeg')
caxis([0 0.05])
subplot(2,2,3)
imagesc(particPos')
caxis([0 1])
subplot(2,2,4)
imagesc(particNeg')
caxis([0 1])

for node = 1:size(corrMat, 1)
    [strPosAccR(node) strPosAccP(node)] =  partialcorr(strengthPos(node, :)', behav1, behav2, 'type', 'Spearman');
    [strNegAccR(node) strNegAccP(node)] =  partialcorr(strengthNeg(node, :)', behav1, behav2, 'type', 'Spearman');
    [parPosAccR(node) parPosAccP(node)] =  partialcorr(particPos(node, :)', behav1, behav2, 'type', 'Spearman');
    [parNegAccR(node) parNegAccP(node)] =  partialcorr(particNeg(node, :)', behav1, behav2, 'type', 'Spearman');
    [strPosLatR(node) strPosLatP(node)] =  partialcorr(strengthPos(node, :)', behav2, behav1, 'type', 'Spearman');
    [strNegLatR(node) strNegLatP(node)] =  partialcorr(strengthNeg(node, :)', behav2, behav1, 'type', 'Spearman');
    [parPosLatR(node) parPosLatP(node)] =  partialcorr(particPos(node, :)', behav2, behav1, 'type', 'Spearman');
    [parNegLatR(node) parNegLatP(node)] =  partialcorr(particNeg(node, :)', behav2, behav1, 'type', 'Spearman');
end

figure(3)
subplot(4,2,1)
stem(strPosAccR, 'r')
hold on
stem(-log(strPosAccP))
title('Postive Strength vs Accuracy')
subplot(4,2,2)
stem(parPosAccR, 'r')
hold on
stem(-log(parPosAccP))
title('Postive Participation vs Accuracy')
subplot(4,2,3)
stem(strNegAccR, 'r')
hold on
stem(-log(strNegAccP))
title('Negative Strength vs Accuracy')
subplot(4,2,4)
stem(parNegAccR, 'r')
hold on
stem(-log(parNegAccP))
title('Negative Participation vs Accuracy')
subplot(4,2,5)
stem(strPosLatR, 'r')
hold on
stem(-log(strPosLatP))
title('Postive Strength vs Latency')
subplot(4,2,6)
stem(parPosLatR, 'r')
hold on
stem(-log(parPosLatP))
title('Postive Participation vs Latency')
subplot(4,2,7)
stem(strNegLatR, 'r')
hold on
stem(-log(strNegLatP))
title('Negative Strength vs Latency')
subplot(4,2,8)
stem(parNegLatR, 'r')
hold on
stem(-log(parNegLatP))
title('Negative Participation vs Latency')

table1 = [strPosAccR' strPosAccP' parPosAccR' parPosAccP' strNegAccR' strNegAccP' parNegAccR' parNegAccP'];
table2 = [strPosLatR' strPosLatP' parPosLatR' parPosLatP' strNegLatR' strNegLatP' parNegLatR' parNegLatP'];
