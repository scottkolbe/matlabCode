close all
figure(1)

betaBrainVol = zeros(size(brainVols, 1), 1);
betaLesionVol = zeros(size(brainVols, 1), 1);
ii = 1;
jj = 1;
kk = 1;
subjToPlotVol = [];
subjToPlotLesion = [];
for subj = 1:size(brainVols, 1)
    X = ageAtScan(subj,:)' ;
    Y = (brainVols(subj,:).*scalingFactors(subj,:))'/1000000;
    X = X(~isnan(X));
    Y = Y(~isnan(Y));
    if length(X) == length(Y) && ~isempty(X) && ~isempty(Y)
        if length(X) > 2
            B = robustfit(X, Y);
            volChange(subj, 1) = B(2);
            Y1 = B(2)*X + B(1);
        elseif length(X) == 2
            B = regress(Y,[ones(length(X), 1) X]);
            volChange(subj,1) = B(2);
            Y1 = B(2)*X + B(1);
        end
        if B(2) < 0.02 && B(2) > -0.02
            subjToPlotVol = [subjToPlotVol; subj];
            if group(subj) == 1
                subplot(3,1,1)
                plot(X,Y, 'ok')
                hold on
                plot(X, Y1, 'k');
                ylim([1.1 1.8])
                xlim([15 60])
                title('NEDA')
                
            elseif group(subj) == 2
                subplot(3,1,2)
                plot(X,Y, 'ok')
                hold on
                plot(X, Y1, 'k');
                ylim([1.1 1.8])
                xlim([15 60])
                title('Relapsed')
                ylabel('Brain Volume (L)')
                jj = jj + 1;
            elseif group(subj) == 3
                subplot(3,1,3)
                plot(X,Y, 'ok')
                hold on
                plot(X, Y1, 'k');
                ylim([1.1 1.8])
                xlim([15 60])
                title('Progressive')
                xlabel('Age (years)')
                kk = kk + 1;
            end
        end
        
    end
    
end
figure(2)
boxplot(volChange(subjToPlotVol, 1), group(subjToPlotVol))
set(gca,'XTickLabel',{'NEDA','Relapsed','Progressive'},'XTick',[1 2 3]);
set(gcf, 'Color',[1 1 1]);
title('BPV Rate of Change');
ylabel('Volume Change (L/yr)');

figure(3)
for subj = 1:size(brainVols, 1)
    X = ageAtScan(subj,:)' ;
    Y = (lesionVols(subj,:).*scalingFactors(subj,:))'/1000000;
    X = X(~isnan(X));
    Y = Y(~isnan(Y));
    if length(X) == length(Y) && ~isempty(X) && ~isempty(Y)
        if length(X) > 2
            B = robustfit(X, Y);
            volChange(subj,2) = B(2);
            Y1 = B(2)*X + B(1);
        elseif length(X) == 2
            B = regress(Y,[ones(length(X), 1) X]);
            volChange(subj,2) = B(2);
            Y1 = B(2)*X + B(1);
        end
        if B(2) < 0.002 && B(2) > -0.002
            subjToPlotLesion = [subjToPlotLesion, subj];
            if group(subj) == 1
                subplot(3,1,1)
                plot(X,Y, 'ok')
                hold on
                plot(X, Y1, 'k');
                ylim([0 0.08])
                xlim([15 60])
                title('NEDA')
            elseif group(subj) == 2
                subplot(3,1,2)
                plot(X,Y, 'ok')
                hold on
                plot(X, Y1, 'k');
                ylim([0 0.08])
                xlim([15 60])
                title('Relapsed')
                ylabel('Lesion Volume (L)')
            elseif group(subj) == 3
                subplot(3,1,3)
                plot(X,Y, 'ok')
                hold on
                plot(X, Y1, 'k');
                ylim([0 0.08])
                xlim([15 60])
                title('Progressive')
                xlabel('Age (years)')
            end
        end
    end
    
end
figure(4)
boxplot(volChange(subjToPlotLesion, 2), group(subjToPlotLesion))
set(gca,'XTickLabel',{'NEDA','Relapsed','Progressive'},'XTick',[1 2 3]);
set(gcf, 'Color',[1 1 1]);
title('Lesion Rate of Change');
ylabel('Volume Change (L/yr)');
