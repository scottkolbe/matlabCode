function [table1, table2] = corrNetworkBehaviour(corrMat, behav1, behav2, modularity, numSamps, numPerms)

% calculate comodularity for each subject and then whole group
% correlat network parameters with behavioural variables
[Y,I] = sort(modularity.CiNewG);

for subj=1:size(corrMat,3)
    thisMat=corrMat(:,:,subj);
    coModSubj = zeros(size(corrMat, 1), size(corrMat, 1), numSamps);
    Ci = zeros(size(corrMat, 1), numSamps);
    % calculate modularity for each sample
    for ii = 1:numSamps
        [Ci, ~]= modularity_louvain_und_sign(thisMat, 'gja');
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
    strengthPos(I,subj) = (Spos./vpos); 
    strengthNeg(I,subj) = (Sneg./vneg);
    [Ppos Pneg] = participation_coef_sign(thisMat,Ci);
    particPos(I,subj) = Ppos;
    particNeg(I,subj) = Pneg;
    disp(sprintf('Number of modules for subject %i = %i', subj, max(Ci)))
    numMod(subj) = max(Ci); 
end


strengthPosG = mean(strengthPos, 2);
strengthNegG = mean(strengthNeg, 2);
strongNodesPos = find(strengthPosG>mean(strengthPosG)+std(strengthPosG));
strongNodesNeg = find(strengthNegG>mean(strengthNegG)+std(strengthNegG));


figure(1)
subplot(2,1,1)
imagesc(strengthPos')
caxis([0 0.05])
subplot(2,1,2)
imagesc(strengthNeg')
caxis([0 0.05])
% subplot(2,2,3)
% imagesc(particPos')
% caxis([0 1])
% subplot(2,2,4)
% imagesc(particNeg')
% caxis([0 1])

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
strPosAccPperm = zeros(size(corrMat, 1), 1);
strNegAccPperm = zeros(size(corrMat, 1), 1);
parPosAccPperm = zeros(size(corrMat, 1), 1);
parNegAccPperm = zeros(size(corrMat, 1), 1);
strPosLatPperm = zeros(size(corrMat, 1), 1);
strNegLatPperm = zeros(size(corrMat, 1), 1);
parPosLatPperm = zeros(size(corrMat, 1), 1);
parNegLatPperm = zeros(size(corrMat, 1), 1);

for perm = 1:numPerms
    A = randperm(length(behav1));
    behav1 = behav1(A);
    A = randperm(length(behav1));
    behav2 = behav2(A);
    disp(sprintf('Testing random permutation %i', perm))
    for node = 1:size(corrMat, 1)
        [strPosAccRthisPerm(node)] =  partialcorr(strengthPos(node, :)', behav1, behav2, 'type', 'Spearman');
        [strNegAccRthisPerm(node)] =  partialcorr(strengthNeg(node, :)', behav1, behav2, 'type', 'Spearman');
        [parPosAccRthisPerm(node)] =  partialcorr(particPos(node, :)', behav1, behav2, 'type', 'Spearman');
        [parNegAccRthisPerm(node)] =  partialcorr(particNeg(node, :)', behav1, behav2, 'type', 'Spearman');
        [strPosLatRthisPerm(node)] =  partialcorr(strengthPos(node, :)', behav2, behav1, 'type', 'Spearman');
        [strNegLatRthisPerm(node)] =  partialcorr(strengthNeg(node, :)', behav2, behav1, 'type', 'Spearman');
        [parPosLatRthisPerm(node)] =  partialcorr(particPos(node, :)', behav2, behav1, 'type', 'Spearman');
        [parNegLatRthisPerm(node)] =  partialcorr(particNeg(node, :)', behav2, behav1, 'type', 'Spearman');
    end
    
    strPosAccPperm(strPosAccR>max(strPosAccRthisPerm)) = strPosAccPperm(strPosAccR>max(strPosAccRthisPerm)) + 1;
    strNegAccPperm(strNegAccR>max(strNegAccRthisPerm)) = strNegAccPperm(strNegAccR>max(strNegAccRthisPerm)) + 1;
    parPosAccPperm(parPosAccR>max(parPosAccRthisPerm)) = parPosAccPperm(parPosAccR>max(parPosAccRthisPerm)) + 1;
    parNegAccPperm(parNegAccR>max(parNegAccRthisPerm)) = parNegAccPperm(parNegAccR>max(parNegAccRthisPerm)) + 1;
    strPosLatPperm(strPosLatR>max(strPosLatRthisPerm)) = strPosLatPperm(strPosLatR>max(strPosLatRthisPerm)) + 1;
    strNegLatPperm(strNegLatR>max(strNegLatRthisPerm)) = strNegLatPperm(strNegLatR>max(strNegLatRthisPerm)) + 1;
    parPosLatPperm(parPosLatR>max(parPosLatRthisPerm)) = parPosLatPperm(parPosLatR>max(parPosLatRthisPerm)) + 1;
    parNegLatPperm(parNegLatR>max(parNegLatRthisPerm)) = parNegLatPperm(parNegLatR>max(parNegLatRthisPerm)) + 1;
    
    strPosAccPperm(strPosAccR<min(strPosAccRthisPerm)) = strPosAccPperm(strPosAccR<min(strPosAccRthisPerm)) + 1;
    strNegAccPperm(strNegAccR<min(strNegAccRthisPerm)) = strNegAccPperm(strNegAccR<min(strNegAccRthisPerm)) + 1;
    parPosAccPperm(parPosAccR<min(parPosAccRthisPerm)) = parPosAccPperm(parPosAccR<min(parPosAccRthisPerm)) + 1;
    parNegAccPperm(parNegAccR<min(parNegAccRthisPerm)) = parNegAccPperm(parNegAccR<min(parNegAccRthisPerm)) + 1;
    strPosLatPperm(strPosLatR<min(strPosLatRthisPerm)) = strPosLatPperm(strPosLatR<min(strPosLatRthisPerm)) + 1;
    strNegLatPperm(strNegLatR<min(strNegLatRthisPerm)) = strNegLatPperm(strNegLatR<min(strNegLatRthisPerm)) + 1;
    parPosLatPperm(parPosLatR<min(parPosLatRthisPerm)) = parPosLatPperm(parPosLatR<min(parPosLatRthisPerm)) + 1;
    parNegLatPperm(parNegLatR<min(parNegLatRthisPerm)) = parNegLatPperm(parNegLatR<min(parNegLatRthisPerm)) + 1;
end
strPosAccPperm = strPosAccPperm./numPerms;
strNegAccPperm = strNegAccPperm./numPerms;
parPosAccPperm = parPosAccPperm./numPerms;
parNegAccPperm = parNegAccPperm./numPerms;
strPosLatPperm = strPosLatPperm./numPerms;
strNegLatPperm = strNegLatPperm./numPerms;
parPosLatPperm = parPosLatPperm./numPerms;
parNegLatPperm = parNegLatPperm./numPerms;


figure(3)
subplot(4,2,1)
stem(strPosAccR, 'r')
hold on
stem((strPosAccPperm))
title('Postive Strength vs Accuracy')

subplot(4,2,2)
stem(parPosAccR, 'r')
hold on
stem((parPosAccPperm))
title('Postive Participation vs Accuracy')

subplot(4,2,3)
stem(strNegAccR, 'r')
hold on
stem((strNegAccPperm))
title('Negative Strength vs Accuracy')

subplot(4,2,4)
stem(parNegAccR, 'r')
hold on
stem((parNegAccPperm))
title('Negative Participation vs Accuracy')

subplot(4,2,5)
stem(strPosLatR, 'r')
hold on
stem((strPosLatPperm))
title('Postive Strength vs Latency')

subplot(4,2,6)
stem(parPosLatR, 'r')
hold on
stem((parPosLatPperm))
title('Postive Participation vs Latency')

subplot(4,2,7)
stem(strNegLatR, 'r')
hold on
stem((strNegLatPperm))
title('Negative Strength vs Latency')

subplot(4,2,8)
stem(parNegLatR, 'r')
hold on
stem((parNegLatPperm))
title('Negative Participation vs Latency')

table1 = [strPosAccR' strPosAccPperm parPosAccR' parPosAccPperm strNegAccR' strNegAccPperm parNegAccR' parNegAccPperm];
table2 = [strPosLatR' strPosLatPperm parPosLatR' parPosLatPperm strNegLatR' strNegLatPperm parNegLatR' parNegLatPperm];
