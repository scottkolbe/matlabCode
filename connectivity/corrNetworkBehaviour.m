function [table1, table2] = corrNetworkBehaviour(corrMat, behav1, behav2, modularity, numPerms, useSubjComod, numSamps)

% calculate comodularity for each subject and then whole group
% correlate network parameters with behavioural variables

[Y,I] = sort(modularity.CiNewG);

for subj=1:size(corrMat,3)
    thisMat=corrMat(:,:,subj);
    if true(useSubjComod)
        
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
    else
        coMod = modularity.coModG;
        Ci = modularity.CiNewG;
    end
    
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
subplot(2,2,1)
imagesc(strengthPos')
caxis([0 0.05])
title('Positive Strength')
subplot(2,2,2)
imagesc(strengthNeg')
caxis([0 0.05])
title('Negative Strength')
subplot(2,2,3)
imagesc(particPos')
caxis([0 1])
title('Positive Participation')
subplot(2,2,4)
imagesc(particNeg')
caxis([0 1])
title('Negative Participation')

for node = 1:size(corrMat, 1)
    [strPosAccR(node) strPosAccP(node)] =  corr(strengthPos(node, :)', behav1,  'type', 'Spearman');
    [strNegAccR(node) strNegAccP(node)] =  corr(strengthNeg(node, :)', behav1,  'type', 'Spearman');
    [parPosAccR(node) parPosAccP(node)] =  corr(particPos(node, :)', behav1,  'type', 'Spearman');
    [parNegAccR(node) parNegAccP(node)] =  corr(particNeg(node, :)', behav1,  'type', 'Spearman');
    [strPosLatR(node) strPosLatP(node)] =  corr(strengthPos(node, :)', behav2,  'type', 'Spearman');
    [strNegLatR(node) strNegLatP(node)] =  corr(strengthNeg(node, :)', behav2,  'type', 'Spearman');
    [parPosLatR(node) parPosLatP(node)] =  corr(particPos(node, :)', behav2,  'type', 'Spearman');
    [parNegLatR(node) parNegLatP(node)] =  corr(particNeg(node, :)', behav2,  'type', 'Spearman');
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
        [strPosAccRthisPerm(node)] =  corr(strengthPos(node, :)', behav1,  'type', 'Spearman');
        [strNegAccRthisPerm(node)] =  corr(strengthNeg(node, :)', behav1,  'type', 'Spearman');
        [parPosAccRthisPerm(node)] =  corr(particPos(node, :)', behav1,  'type', 'Spearman');
        [parNegAccRthisPerm(node)] =  corr(particNeg(node, :)', behav1,  'type', 'Spearman');
        [strPosLatRthisPerm(node)] =  corr(strengthPos(node, :)', behav2,  'type', 'Spearman');
        [strNegLatRthisPerm(node)] =  corr(strengthNeg(node, :)', behav2,  'type', 'Spearman');
        [parPosLatRthisPerm(node)] =  corr(particPos(node, :)', behav2,  'type', 'Spearman');
        [parNegLatRthisPerm(node)] =  corr(particNeg(node, :)', behav2,  'type', 'Spearman');
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
strPosAccPperm = 1- strPosAccPperm./numPerms;
strNegAccPperm = 1- strNegAccPperm./numPerms;
parPosAccPperm = 1- parPosAccPperm./numPerms;
parNegAccPperm = 1- parNegAccPperm./numPerms;
strPosLatPperm = 1- strPosLatPperm./numPerms;
strNegLatPperm = 1- strNegLatPperm./numPerms;
parPosLatPperm = 1- parPosLatPperm./numPerms;
parNegLatPperm = 1- parNegLatPperm./numPerms;


figure(3)
subplot(4,2,1)
stem(strPosAccR, 'r')
hold on
stem(-log(strPosAccPperm))
title('Postive Strength vs Accuracy')
ylim([-1, 3])
hold off

subplot(4,2,2)
stem(parPosAccR, 'r')
hold on
stem(-log(parPosAccPperm))
title('Postive Participation vs Accuracy')
ylim([-1, 3])
hold off

subplot(4,2,3)
stem(strNegAccR, 'r')
hold on
stem(-log(strNegAccPperm))
title('Negative Strength vs Accuracy')
ylim([-1, 3])
hold off

subplot(4,2,4)
stem(parNegAccR, 'r')
hold on
stem(-log(parNegAccPperm))
title('Negative Participation vs Accuracy')
ylim([-1, 3])
hold off

subplot(4,2,5)
stem(strPosLatR, 'r')
hold on
stem(-log(strPosLatPperm))
title('Postive Strength vs Latency')
ylim([-1, 3])
hold off

subplot(4,2,6)
stem(parPosLatR, 'r')
hold on
stem(-log(parPosLatPperm))
title('Postive Participation vs Latency')
ylim([-1, 3])
hold off

subplot(4,2,7)
stem(strNegLatR, 'r')
hold on
stem(-log(strNegLatPperm))
title('Negative Strength vs Latency')
ylim([-1, 3])
hold off

subplot(4,2,8)
stem(parNegLatR, 'r')
hold on
stem(-log(parNegLatPperm))
title('Negative Participation vs Latency')
ylim([-1, 3])
hold off

table1 = [strPosAccR' strPosAccPperm parPosAccR' parPosAccPperm strNegAccR' strNegAccPperm parNegAccR' parNegAccPperm];
table2 = [strPosLatR' strPosLatPperm parPosLatR' parPosLatPperm strNegLatR' strNegLatPperm parNegLatR' parNegLatPperm];
