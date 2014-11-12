function callDetection = callROC(sonogram, manCallTimes, classifications)

%% this function will calculate TPs and FPs for varying parameters input to whistimes_SK

[sng,header] = ReadSonogram(sonogram);
f = linspace(0,header.scanrate/2000,header.nfreq);
t = linspace(0,header.nscans/header.scanrate,header.columnTotal);

xlim = [min(t) max(t)];
ylim = [min(f) max(f)];
[i,j,s] = find(sng);
s = abs(s);
snorm = s/min(s);
lsnorm = log10(snorm);
spm = sparse(i,j,lsnorm,size(sng,1),size(sng,2));

options.log = 0;
options.filterduration = 0.01;
options.maxpowerthresh = 0.15;
options.durationthresh = 0.005;
options.mergeclose = 0.015;

%% first run an ROC for various dividers
figProgress=waitbar(0,'Checking for Divider = 0');
for test = 1:5:100
    options.divider = test/100;
    figProgress=waitbar(test/100,...
        figProgress,...
        sprintf('Checking for Divider = %0.2f', options.divider));
        
    [callTimes,outdata] = whistimes_SK(spm, header, options);
    callComparison = checkCalls(callTimes, manCallTimes, classifications, 0);
    callDetection.divider.TP(test+1) = callComparison.detection.numTP.man;
    callDetection.divider.FP(test+1) = callComparison.detection.numFP.auto;
    callDetection.divider.FN(test+1) = callComparison.detection.numFN.man;
    
end

close(figProgress)

options.divider = 0.36;

%% first run an ROC for various purity thresholds
figProgress=waitbar(0,'Checking for Spectral Purity = 0');
for test = 80:5:100
    options.puritythresh = test/100;
    figProgress=waitbar(test/100,...
        figProgress,...
        sprintf('Checking for Spectral Purity = %0.2f', options.puritythresh));
        
    [callTimes,outdata] = whistimes_SK(spm, header, options);
    callComparison = checkCalls(callTimes, manCallTimes, classifications, 0);
    callDetection.purity.TP(test+1) = callComparison.detection.numTP.man;
    callDetection.purity.FP(test+1) = callComparison.detection.numFP.auto;
    callDetection.purity.FN(test+1) = callComparison.detection.numFN.man;
    
end

close(figProgress)

%% now run a ROC for various maxpower thresholds with optimal purity thresh (0.935)
options.puritythresh = 0.95;

figProgress=waitbar(0,'Checking for Max Power Threshold = 0');
for test = 0:5:100
    options.maxpowerthresh = test/100;
    figProgress=waitbar(test/100,...
        figProgress,...
        sprintf('Checking for Max Power Threshold = %0.2f', options.maxpowerthresh));
        
    [callTimes,outdata] = whistimes_SK(spm, header, options);
    callComparison = checkCalls(callTimes, manCallTimes, classifications, 0);
    callDetection.maxpower.TP(test+1) = callComparison.detection.numTP.man;
    callDetection.maxpower.FP(test+1) = callComparison.detection.numFP.auto;
    callDetection.maxpower.FN(test+1) = callComparison.detection.numFN.man;
end
close(figProgress)

figure(1)

subplot(2,1,1)
stem(callDetection.divider.TP);
hold on
stem(callDetection.divider.FP,'r');
stem(callDetection.divider.FN, 'g');
legend('TP', 'FP', 'FN', 'Location', 'NorthWest');
xlabel('Divider (%)');
ylabel('Number of Calls');

subplot(2,1,2)
stem(callDetection.purity.TP);
hold on
stem(callDetection.purity.FP,'r');
stem(callDetection.purity.FN, 'g');
legend('TP', 'FP', 'FN', 'Location', 'NorthWest');
xlabel('Spectral Purity (%)');
ylabel('Number of Calls');

subplot(2,1,3)
stem(callDetection.maxpower.TP);
hold on
stem(callDetection.maxpower.FP,'r');
stem(callDetection.maxpower.FN,'g');
legend('TP', 'FP', 'FN', 'Location', 'NorthWest');
xlabel('Maximum Power Threshold (%)');
ylabel('Number of Calls');
