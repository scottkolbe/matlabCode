goodAcc = find(AS_latency<median(AS_latency));
badAcc = find(AS_latency>median(AS_latency));

badAccMod = mean(meanCoModSubj(:,:,badAcc), 3);
goodAccMod = mean(meanCoModSubj(:,:,goodAcc), 3);

[Cibad, ~]=modularity_und(badAccMod);
for nodeI=1:size(Cibad,1)
    for nodeJ=1:size(Cibad,1)
        if Cibad(nodeI)==Cibad(nodeJ)
            coModBad(nodeI,nodeJ) = 1;
        end
    end
end

[Cigood, ~]=modularity_und(goodAccMod);
for nodeI=1:size(Cigood,1)
    for nodeJ=1:size(Cigood,1)
        if Cigood(nodeI)==Cigood(nodeJ)
            coModGood(nodeI,nodeJ) = 1;
        end
    end
end


figure
subplot(2,2,1)
imagesc(badAccMod)
subplot(2,2,2)
imagesc(goodAccMod)
subplot(2,2,3)
imagesc(coModBad)
subplot(2,2,4)
imagesc(coModGood)
