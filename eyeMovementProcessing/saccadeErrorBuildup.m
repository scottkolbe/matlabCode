saccType = A(:,1);
absError = A(:,2);
saccTypeToUse = 1;
saccInds = intersect(find(absError > 0), find(saccType == saccTypeToUse));
numPrevAS = zeros(size(saccInds));

for ii = 1:length(saccInds)
      
    if saccInds(ii) == 1
        numPrevAS(ii) = 0;
    end
    
    if saccInds(ii) > 1
        if saccType(saccInds(ii)-1) == 1
            numPrevAS(ii) = 1;
        end
    end
    
    if saccInds(ii) > 2
        if saccType(saccInds(ii)-1) == 1 && saccType(saccInds(ii)-2) == 1
            numPrevAS(ii) = 2;
        end
    end
    
%     if saccInds(ii) > 3
%         if saccType(saccInds(ii)-1) == 1 && saccType(saccInds(ii)-2) == 1 && saccType(saccInds(ii)-3) == 1
%             numPrevAS(ii) = 3;
%         end
%     end
    
%     if saccInds(ii) > 4
%         if saccType(saccInds(ii)-1) == 1 && saccType(saccInds(ii)-2) == 1 && saccType(saccInds(ii)-3) == 1 && saccType(saccInds(ii)-4) == 1
%             numPrevAS(ii) = 4;
%         end
%     end
%     
%     if saccInds(ii) > 5
%         if saccType(saccInds(ii)-1) == 1 && saccType(saccInds(ii)-2) == 1 && saccType(saccInds(ii)-3) == 1 && saccType(saccInds(ii)-4) == 1 && saccType(saccInds(ii)-5) == 1
%             numPrevAS(ii) = 5;
%         end
%     end
%     
%     if saccInds(ii) > 6
%         if saccType(saccInds(ii)-1) == 1 && saccType(saccInds(ii)-2) == 1 && saccType(saccInds(ii)-3) == 1 && saccType(saccInds(ii)-4) == 1 && saccType(saccInds(ii)-5) == 1 && saccType(saccInds(ii)-6) == 1
%             numPrevAS(ii) = 6;
%         end
%     end
%     
end

figure
ASError = absError(saccInds);
boxplot(ASError, numPrevAS)