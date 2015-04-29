function [meanConn, stdConn] = permConnPCA(corrMat, coeffThresh, behavVect, toWeight)

meanZmat = mean(corrMat, 3);
[coeff, ~, explained] = pcacov(meanZmat);
dims = [size(corrMat, 1), size(corrMat, 2),size(corrMat, 3)];

figure(1)
imagesc(coeff(:,1:4))

coeff(coeff < coeffThresh) = 0;

%% calculate weight matrix for each network
weightMat = zeros(size(corrMat, 1), size(corrMat, 1), 4, 4);
figure(2)
for comp1 = 1:4
    for comp2 = 1:4
        netweights1 = coeff(:,comp1);
        netweights2 = coeff(:,comp2);
        
        % calculate weighted correlation matrix for each subject
        for ii = 1:size(netweights1, 1)
            for jj = 1:size(netweights2, 1)
                weightMat(ii,jj, comp1, comp2) = ((netweights1(ii) * netweights2(jj)) + (netweights1(jj) * netweights2(ii)))^0.5;
                if ii == jj
                    weightMat(ii,jj,comp1, comp2) = weightMat(ii,jj,comp1, comp2)/2;
                end
            end
        end
        
        position = (comp1*4 -4 + comp2);
        subplot(4,4,position)
        imagesc(weightMat(:,:,comp1, comp2))
        caxis([0 0.4])
    end
end


%% calculate weighted mean and std connecitivity for each network for each subject
meanConn = zeros(dims(3), 4,4);
stdConn = zeros(dims(3), 4,4);

for comp1 = 1:4
    for comp2 = 1:4
        for subj = 1:dims(3)
            weights = squeeze(weightMat(:,:,comp1,comp2));
            weightVect = weights(find(triu(weights)));
            conn = corrMat(:,:,subj);
            connVect = conn(find(triu(weights)));
            weightVect = weightVect(find(connVect));
            connVect = connVect(find(connVect));
            if true(toWeight)
                meanConn(subj, comp1,comp2) = sum(weightVect.*connVect) ./ sum(weightVect);
                stdConn(subj, comp1,comp2) = (sum(weightVect.*((connVect-meanConn(subj, comp1, comp2)).^2)) ./ sum(weightVect))^0.5;
            else
                meanConn(subj, comp1,comp2) = mean(connVect);
                stdConn(subj, comp1,comp2) = std(connVect);
            end
            
        end
        figure(3)
        position = (comp1*4 -4 + comp2);
        subplot(4,4,position)
        scatter(meanConn(:,comp1, comp2), behavVect)
        figure(4)
        position = (comp1*4 -4 + comp2);
        subplot(4,4,position)
        scatter(stdConn(:,comp1, comp2), behavVect)
        
    end
    
end

