function [callTimes, allCalls, allCallsSmoothed] = usvSpectro(matFile, plotem)


%% display and check spectrogram - change threshold and freq range as necessary and reanalyse
[sng,header] = ReadSonogram(matFile);

f = linspace(0,header.scanrate/2000,header.nfreq);
t = linspace(0,header.nscans/header.scanrate,header.columnTotal);

xlim = [min(t) max(t)];
ylim = [min(f) max(f)];
[i,j,s] = find(sng);
s = abs(s);
snorm = s/min(s);
lsnorm = log10(snorm);
spm = sparse(i,j,lsnorm,size(sng,1),size(sng,2));



%% set parameters and run
options.log = 0;
options.filterduration = 0.02;
options.puritythresh = 0.90;
options.maxpowerthresh = 0.15;
options.durationthresh = 0.005;
options.mergeclose = 0.015;
options.divider = 0.33;

[callTimes,outdata] = whistimes_SK(spm, header, options);

checkCalls(callTimes, manCallTimes, classifications, 1);

multiplier = header.columnTotal/(header.nscans/header.scanrate);

%% check and reanalyse with different parameters if necessary
if true(plotem);

    plotWindow = 300;
    
    for windowNum = 1:floor(size(spm,2)/plotWindow)

        currWindow = windowNum*plotWindow:windowNum*plotWindow+plotWindow;

        imagesc(flipud(spm(:,currWindow))); colormap gray;
        hold on

        A = find(callTimes(1, :) > t(currWindow(1)));
        B = find(callTimes(1, :) < t(currWindow(end)));
        currStartInds = intersect(A,B);
        C = find(callTimes(1, :) > t(currWindow(1)));
        D = find(callTimes(1, :) < t(currWindow(end)));
        currEndInds = intersect(C,D);

        if ~isempty(currStartInds) 
            for whist = 1:length(currStartInds)
                x = [ceil(callTimes(1,currStartInds(whist))*multiplier -currWindow(1))' ...
                ceil(callTimes(1,currStartInds(whist))*multiplier -currWindow(1))'];
                y = [1; sngparms.nfreq];
                plot(x, y, 'g');
            end
        end

        if ~isempty(currEndInds) 
            for whist = 1:length(currEndInds)
                x = [ceil(callTimes(2,currStartInds(whist))*multiplier -currWindow(1))' ...
                ceil(callTimes(2,currStartInds(whist))*multiplier -currWindow(1))'];
                y = [1; sngparms.nfreq];
                plot(x, y, 'y');
            end
        end


        plot(513-(outdata(1).value(currWindow)*512),'oc')
        plot(513-(outdata(2).value(currWindow)*512),'r')

        thresh1 = ones(size(currWindow)) * 513-options.puritythresh*512;
        thresh2 = ones(size(currWindow)) * 513-options.maxpowerthresh*512;
        plot(thresh1, 'c')
        plot(thresh2, 'r')

        title(sprintf('Window number %i', windowNum));

        hold off

        pause
    end

end

%% isolate and time normalise calls 
allCalls = cell(size(callTimes,2),1);
allCallsSmoothed = cell(size(callTimes,2),1);
figProgress=waitbar(0,'Time warping call 0');

for callToAnalyse = 1:size(callTimes,2)
    figProgress=waitbar(callToAnalyse/size(callTimes,2),...
        figProgress,...
        sprintf('Time warping and smoothing call %i of %i', callToAnalyse, size(callTimes,2)));
    onset = callTimes(1,callToAnalyse);
    offset = callTimes(2,callToAnalyse);

    % convert timestamp to index
    sampleTime = (header.nscans/header.scanrate)/header.columnTotal;
    onsetInd = onset/sampleTime;
    offsetInd = offset/sampleTime;
    call = spm(:,onsetInd:offsetInd);
    
    % reslice to 513*513
    call = full(call);
    for t = 1:513
        vectToUse = ceil(0:size(call,2)/512:size(call,2));
        vectToUse(1) = 1;
        callInterp(:,t) = call(:,vectToUse(t));
    end
    
    allCalls{callToAnalyse} = sparse(callInterp);
      
    % also make a smoothed version to assist in clustering.
    H = fspecial('disk',30);
    allCallsSmoothed{callToAnalyse} = sparse(imfilter(callInterp, H,'replicate'));
    
    
end







