function [FWERCorrP, unpermutedR] = corrFWER(data, dataType, behavData1, behavData2, pThresh, numSamps)

% start parallel matlab pool if not already open
if isempty(gcp)
    parpool('local');
end

switch dataType
    case 1 % volumetric MRI data
        fprintf('You are analysing MRI data, using voxel cluster thresholding\n')
        
        % reshape 4D image for parallel processing
        reshapedImg = reshape(data, [size(data, 1)*size(data, 2)*size(data, 3), size(data, 4)]);
        
        unpermutedR = zeros(size(reshapedImg, 1), 1);
        unpermutedP = ones(size(reshapedImg, 1), 1);
        
        % calculate test statistic for unpermuted data
        parfor vox = 1:size(reshapedImg, 1)
            dataVect = squeeze(reshapedImg(vox, :))';
            if length(dataVect==0) ~= 0
                [unpermutedR(vox), unpermutedP(vox)] = partialcorr(dataVect, behavData1, behavData2, 'type', 'Spearman');
            end
        end
        
        % reshape p-value map and create significance mask with labeled
        % connected components
        unpermutedP = reshape(unpermutedP, size(data, 1),size(data, 2),size(data, 3));
        unpermutedR = reshape(unpermutedR, size(data, 1),size(data, 2),size(data, 3));
        unpermutedSignif = zeros(size(unpermutedP, 1), size(unpermutedP, 2), size(unpermutedP, 3));
        unpermutedSignif(unpermutedP < pThresh) = 1;
        
        % find the size of each connected component
        [connectedSignif, numClusters] = bwlabeln(unpermutedSignif);
        for cluster = 1:numClusters
            clusterSize(cluster) = length(find(connectedSignif == cluster));
        end
        
       
        
        %% permute behavioural data to calculate FWER cluster corrected P-value
        FWERCorrP = zeros(size(reshapedImg, 1), 1);
        permutedP = ones(size(reshapedImg, 1), 1);
        permutedR = zeros(size(reshapedImg, 1), 1);
        
        for samp = 1:numSamps
            fprintf('Analysing sample %i of %i\n', samp, numSamps);
            
            permBehavData1 = behavData1(randperm(length(behavData1)));
            permBehavData2 = behavData2(randperm(length(behavData2)));
            parfor vox = 1:size(reshapedImg, 1)
                dataVect = squeeze(reshapedImg(vox, :))';
                if length(dataVect==0) ~= 0
                    [permutedR(vox), permutedP(vox)] = partialcorr(dataVect, permBehavData1, permBehavData2, 'type', 'Spearman');
                end
            end
            
            permutedP = reshape(permutedP, size(data, 1),size(data, 2),size(data, 3));
            permutedR = reshape(permutedR, size(data, 1),size(data, 2),size(data, 3));
            permutedSignif = zeros(size(permutedP, 1), size(permutedP, 2), size(permutedP, 3));
            permutedSignif(permutedP < pThresh) = 1;
            
            [connectedSignifPerm, numClustersPerm] = bwlabeln(permutedSignif);
            for cluster = 1:numClustersPerm
                clusterSizePerm(cluster) = length(find(connectedSignifPerm == cluster));
            end
            
            for cluster = 1:numClusters
                if clusterSize(cluster) > max(clusterSizePerm)
                    IDX = find(connectedSignif == cluster);
                    FWERCorrP(IDX) = FWERCorrP(IDX) + 1;
                end
            end
            
        end
        
        FWERCorrP =  reshape(FWERCorrP, size(data, 1),size(data, 2),size(data, 3));
        FWERCorrP = FWERCorrP/numSamps;
        
        
    case 2 % 2D connectivity data
        fprintf('You are analysing connectivity data, using connection cluster thresholding\n')
        
        % reshape 3D connectivity matrix for parallel processing
        reshapedMat = reshape(data, [size(data, 1)*size(data, 2), size(data, 3)]);
        
        unpermutedR = zeros(size(reshapedMat, 1), 1);
        unpermutedP = ones(size(reshapedMat, 1), 1);
        
        % calculate test statistic for unpermuted data
        parfor conn = 1:size(reshapedMat, 1)
            dataVect = squeeze(reshapedMat(conn, :))';
            if length(dataVect==0) ~= 0
                [unpermutedR(conn), unpermutedP(conn)] = partialcorr(dataVect, behavData1, behavData2, 'type', 'Spearman');
            end
        end
        
        % reshape p-value map and create significance mask with labeled
        % connected components
        unpermutedP = reshape(unpermutedP, size(data, 1),size(data, 2));
        unpermutedR = reshape(unpermutedR, size(data, 1),size(data, 2));
        testStat = unpermutedP(find(triu(unpermutedP)));
        testStat = testStat(~isnan(testStat));
        
        
        % find the size of each connected component
        N = size(data, 1); %number of nodes
        J = N*(N-1)/2; %number of edges
        ind_upper=find(triu(ones(N,N),1));
        ind=ind_upper(testStat<pThresh);
        unpermAdj=zeros(N,N);
        unpermAdj(ind)=1;
        unpermAdj=unpermAdj+unpermAdj';
        [unpermCompNodes,Size]=get_components(unpermAdj);
        unpermIndSz=find(Size>1);
        unpermSzLinks=zeros(1,length(unpermIndSz));
        max_sz=0;
        for ii=1:length(unpermIndSz)
            nodes=find(unpermIndSz(ii)==unpermCompNodes);
            unpermSzLinks(ii)=sum(sum(unpermAdj(nodes,nodes)))/2;
            unpermAdj(nodes,nodes)=unpermAdj(nodes,nodes)*(ii+1);
            if max_sz<unpermSzLinks(ii)
                max_sz=unpermSzLinks(ii);
            end
        end
        unpermAdj(~~unpermAdj)=unpermAdj(~~unpermAdj)-1;
        
        %% permute behavioural data
        
        permutedP = ones(N,N);
        FWERCorrP = zeros(N,N);
        for samp = 1:numSamps
            fprintf('Analysing sample %i of %i\n', samp, numSamps);
            
            permBehavData1 = behavData1(randperm(length(behavData1)));
            permBehavData2 = behavData2(randperm(length(behavData2)));
            parfor conn = 1:size(reshapedMat, 1)
                dataVect = squeeze(reshapedMat(conn, :))';
                if length(find(dataVect)) ~=0
                    [~, permutedP(conn)] = partialcorr(dataVect, permBehavData1, permBehavData2, 'type', 'Spearman');
                end
            end
            
            permutedP = reshape(permutedP, size(data, 1),size(data, 2));
            testStat = permutedP(find(triu(permutedP)));
            testStat = testStat(~isnan(testStat));
            
            % find the size of each connected component
            ind_upper=find(triu(ones(N,N),1));
            ind=ind_upper(testStat<pThresh);
            permAdj=zeros(N,N);
            permAdj(ind)=1;
            permAdj=permAdj+permAdj';
            [permCompNodes,Size]=get_components(permAdj);
            permIndSz=find(Size>1);
            permSzLinks=zeros(1,length(permIndSz));
            for ii=1:length(permIndSz)
                nodes=find(permIndSz(ii)==permCompNodes);
                permSzLinks(ii)=sum(sum(permAdj(nodes,nodes)))/2;
            end
            
            % check unpermuted component sizes against max permuted
            % component size
            for ii = 1:length(unpermSzLinks)
                if unpermSzLinks(ii) > max(permSzLinks)
                    FWERCorrP(find(unpermAdj == ii)) = FWERCorrP(find(unpermAdj == ii)) + 1;
                end
            end
            
        end
        
        FWERCorrP = FWERCorrP/(numSamps-1);
end


