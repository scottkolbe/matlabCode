% need to compare each mouse to a null distribution of path probabilities
% taken from the same number of observations
numItems = 4;
numSamps = 0;
figure
hold on

for mouse = 1:48
    disp(sprintf('Analysing Mouse %i of 48', mouse));
    mouseSeq = allMouseSeq(:,mouse);
    mouseSeq = mouseSeq(find(mouseSeq));
    
    numChecks(mouse) = length(mouseSeq);
    %mouseProbs = zeros(numItems,numItems,numItems,numItems, 48);
    %% calculate mouse distribution of probs
    for A = 1:numItems
        for B = 1:numItems
            for C = 1:numItems
                for D = 1:numItems
                    tally = 0;
                    for seqToTest = 1:numChecks(mouse) - 3
                        if mouseSeq(seqToTest:seqToTest+3) == [A; B; C; D];
                            tally = tally + 1;
                        end
                    end
                    mouseProbs(A,B,C,D, mouse) = tally;
                end
            end
        end
        
    end
    
   
    
    % plot distributions
    
    %[randF,randX] = ecdf(reshape(randProbs, [4*4*4*4, 1]));
    [mouseF,mouseX] = ecdf(reshape(mouseProbs(:,:,:,:,mouse), [4*4*4*4, 1]));
    %plot(randX, randF, 'k');
    if mouse <= 21
        plot(mouseX, mouseF, 'r');
    elseif mouse >= 22
        plot(mouseX, mouseF, 'b');
    end
    
end

