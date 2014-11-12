plotWindow = 300;
    
    for windowNum = 1:floor(size(spm,2)/plotWindow)

        currWindow = windowNum*plotWindow:windowNum*plotWindow+plotWindow;

        imagesc(flipud(spm(:,currWindow))); colormap gray;
        hold on

        A = find(EBCalls(1, :) > t(currWindow(1)));
        B = find(EBCalls(1, :) < t(currWindow(end)));
        currStartInds = intersect(A,B);
        C = find(EBCalls(1, :) > t(currWindow(1)));
        D = find(EBCalls(1, :) < t(currWindow(end)));
        currEndInds = intersect(C,D);

        if ~isempty(currStartInds) 
            for whist = 1:length(currStartInds)
                x = [ceil(EBCalls(1,currStartInds(whist))*multiplier -currWindow(1))' ...
                ceil(EBCalls(1,currStartInds(whist))*multiplier -currWindow(1))'];
                y = [1; sngparms.nfreq];
                plot(x, y, 'g');
            end
        end

        if ~isempty(currEndInds) 
            for whist = 1:length(currEndInds)
                x = [ceil(EBCalls(2,currStartInds(whist))*multiplier -currWindow(1))' ...
                ceil(EBCalls(2,currStartInds(whist))*multiplier -currWindow(1))'];
                y = [1; sngparms.nfreq];
                plot(x, y, 'y');
            end
        end


%         plot(513-(outdata(1).value(currWindow)*512),'oc')
%         plot(513-(outdata(2).value(currWindow)*512),'r')
% 
%         thresh1 = ones(size(currWindow)) * 513-options.puritythresh*512;
%         thresh2 = ones(size(currWindow)) * 513-options.maxpowerthresh*512;
%         plot(thresh1, 'c')
%         plot(thresh2, 'r')

        title(sprintf('Window number %i', windowNum));

        hold off

        pause
    end
