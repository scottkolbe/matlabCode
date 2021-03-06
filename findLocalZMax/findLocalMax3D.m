function [localMax, localMaxSubs] = findLocalMax3D(zStatThreshImg, searchRadius)

% This script finds local maxima for use in creating ROIs for subsequent
% connectivity analyses

if searchRadius < min(size(zStatThreshImg))/2
    
    %% initialise output matrix
    localMax = zeros(size(zStatThreshImg, 1), size(zStatThreshImg, 2), size(zStatThreshImg, 3));
    localMaxSubs = [];
    %% search each image voxel to determine whether that voxel has the highest
    %% value of its local volume based on searchRadius
    volCount = 1;
    for ii=1:size(zStatThreshImg, 1)
        for jj = 1:size(zStatThreshImg, 2)
            for kk = 1:size(zStatThreshImg, 3)
                
                if zStatThreshImg(ii,jj,kk) > 0
                    
                    XtoSearch = ii-searchRadius:ii+searchRadius;
                    if ~isempty(find(XtoSearch<1))
                        firstInd = find(XtoSearch == 1);
                        XtoSearch = XtoSearch(firstInd:end);
                    elseif ~isempty(find(XtoSearch > size(zStatThreshImg, 1)))
                        lastInd = find(XtoSearch == size(zStatThreshImg, 1));
                        XtoSearch = XtoSearch(1:lastInd);
                    end
                    
                    YtoSearch = jj-searchRadius:jj+searchRadius;
                    if ~isempty(find(YtoSearch<1))
                        firstInd = find(YtoSearch == 1);
                        YtoSearch = YtoSearch(firstInd:end);
                    elseif ~isempty(find(YtoSearch > size(zStatThreshImg, 2)))
                        lastInd = find(YtoSearch == size(zStatThreshImg, 2));
                        YtoSearch = YtoSearch(1:lastInd);
                    end
                    
                    ZtoSearch = kk-searchRadius:kk+searchRadius;
                    if ~isempty(find(ZtoSearch<1))
                        firstInd = find(ZtoSearch == 1);
                        ZtoSearch = ZtoSearch(firstInd:end);
                    elseif ~isempty(find(ZtoSearch > size(zStatThreshImg, 3)))
                        lastInd = find(ZtoSearch == size(zStatThreshImg, 3));
                        ZtoSearch = ZtoSearch(1:lastInd);
                    end
                    
                    
                    testMat = zStatThreshImg(XtoSearch, YtoSearch, ZtoSearch);
                    
                    testVect = reshape(testMat, size(testMat, 1)*...
                        size(testMat, 2)*size(testMat, 3), 1);
                    [Y,maxInd] = max(testVect);
                    if length(find(testVect == Y)) == 1
                        [maxTestX,maxTestY,maxTestZ] = ind2sub(size(testMat),maxInd);
                        if ii == XtoSearch(maxTestX) && ...
                                jj == YtoSearch(maxTestY) && ...
                                kk == ZtoSearch(maxTestZ) 
                            
                            localMax(ii,jj,kk,volCount) = 1;
                            localMaxSubs = [localMaxSubs; ii jj kk];
                            volCount = volCount + 1;
                        end
                    else
                        for localMaxPoint = 1:length(find(testVect == Y))
                            A = find(testVect == Y);
                            [maxTestX,maxTestY,maxTestZ] = ...
                                ind2sub(size(testMat),A(localMaxPoint));
                            if ii == XtoSearch(maxTestX) && ...
                                    jj == YtoSearch(maxTestY) && ...
                                    kk == ZtoSearch(maxTestZ) 
                                
                                localMax(ii,jj,kk,volCount) = 1;
                                localMaxSubs = [localMaxSubs; ii jj kk];
                                volCount = volCount + 1;
                            end
                        end
                        
                    end
                end
                
            end
        end
    end
    
else
    disp('Search matrix is larger than the input Matrix\n')
    disp('Finding max of entire image instead\n')
    localMax = max(max(max(zStatThreshImg)));
end
