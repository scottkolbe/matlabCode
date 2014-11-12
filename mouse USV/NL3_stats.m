data3 = reshape(data, [4 28 10]);
data3 = permute(data3, [2 3 1]);

WT = find(data3(:,3,1) == 0);
KI = find(data3(:,3,1) == 1);
noTreat = find(data3(:,4,1) == 0);
Treat = find(data3(:,4,1) == 1);

WTNT = intersect(WT,noTreat);
WTT = intersect(WT,Treat);
KINT = intersect(KI,noTreat);
KIT = intersect(KI,Treat);

bootsamps = 10;

subj = data3(:,1,1);

% for samp = 1:bootsamps
%     
%     currTime = ceil(4*rand(size(uniqSubj)));
%     currGene = diag(squeeze(data3(:,3,currTime)));
%     currDrug = diag(squeeze(data3(:,4,currTime)));
%     currLatency = diag(squeeze(data3(:,6,currTime)));

for time = 1:4
    
    currGene = data3(:,3,time);
    currDrug = data3(:,4,time);
    currLatency = data3(:,6,time);
    
    currWTNTlat = currLatency(WTNT);
    currWTTlat = currLatency(WTT);
    currKINTlat = currLatency(KINT);
    currKITlat = currLatency(KIT);
  
    Y = [currWTNTlat;currWTTlat;currKINTlat;currKITlat];
    Yranks = tiedrank(Y);
    G = [zeros(size(currWTNTlat)); zeros(size(currWTTlat));ones(size(currKINTlat));ones(size(currKITlat))];
    D = [zeros(size(currWTNTlat)); ones(size(currWTTlat));zeros(size(currKINTlat));ones(size(currKITlat))];
    
    [~, Table] = anovan(Y,{G D},'model','interaction');%, 'display', 'off');
    
    GF(samp) = Table{2,6};
    Gp(samp) = Table{2,7};
    DF(samp) = Table{3,6};
    Dp(samp) = Table{3,7};
    IntF(samp) = Table{4,6};
    Intp(samp) = Table{4,7};
    pause
   
    
    
    
end

subplot(3,2,1)
hist(GF)
subplot(3,2,2)
hist(Gp)
subplot(3,2,3)
hist(DF)
subplot(3,2,4)
hist(Dp)
subplot(3,2,5)
hist(IntF)
subplot(3,2,6)
hist(Intp)

medGF = mode(GF)
medGp = mode(Gp)
meddF = mode(DF)
medDp = mode(Dp)
medIntF = mode(IntF)
medIntp = mode(Intp)


