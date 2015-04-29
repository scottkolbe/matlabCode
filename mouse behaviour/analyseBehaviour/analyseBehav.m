function behavOutput = analyseBehav(pnm, fnm, toPlot, toSave)

%% analyses mouse behaviour scoring files from the checkPress script
%%
%% outputs the indices, onsets and durations for each unique behaviour
%%
%% will optionally save output to a MAT file in same directory as input
%%

% load file
load([pnm fnm]);

% change first and last messages to 'other'
if ~isempty(cell2mat(strfind(output.msg, 'startExpt'))) && ...
        ~isempty(cell2mat(strfind(output.msg, 'endExpt')))
    output.msg{strcmp('startExpt', output.msg)} = 'other';
    output.msg{strcmp('endExpt', output.msg)} = 'other';
    
    % find behaviours occuring before end of expt (<300s)
    validInds = find(output.times < 300);
    validInds = validInds(1:end-1);
    allBehavs = cell(length(validInds), 1);
    for ii = 1:length(validInds)
        allBehavs{ii} = output.msg{validInds(ii)};
    end
    
    % calculate and plot onsets and durations for each behaviour
    behavs = unique(allBehavs);
    allOnsets = output.times(validInds);
    allDurations = [allOnsets(2:end);300] - allOnsets(1:end);
    
    if true(toPlot)
        figure('Color',[1 1 1])
    end
    
    behavOrd = cell(length(behavs),1);
    onsets = cell(length(behavs),1);
    durations = cell(length(behavs),1);
    for ii = 1:length(behavs)
        behavOrd{ii} = find(strcmp(allBehavs, behavs{ii}));
        onsets{ii} = allOnsets(behavOrd{ii});
        durations{ii} = allDurations(behavOrd{ii});
        
        % plot onsets and durations
        if true(toPlot)
            scatter(onsets{ii},ones(length(onsets{ii}),1)*ii, 'ok');
            hold on
            for jj = 1:length(onsets{ii})
                plot([onsets{ii}(jj) onsets{ii}(jj)+durations{ii}(jj)],[ii ii], 'k');
            end
        end
    end
    
    if true(toPlot)
        hold off
        ylim([0.5 length(behavs)+0.5])
        set(gca,'YTick',1:length(behavs),'YTickLabel',behavs,'FontSize',14);
        ylabel('Behaviour')
        xlabel('Time (s)')
    end
    
    % save behaviour names, order, onsets and durations
    behavOutput.names = behavs;
    behavOutput.order = behavOrd;
    behavOutput.onsets = onsets;
    behavOutput.durations = durations;
    
    if true(toSave)
        save([pnm fnm(1:end-4) '_analysed.mat'], behavOutput)
    end
    
else
    behavOutput.names = [];
    behavOutput.order = [];
    behavOutput.onsets = [];
    behavOutput.durations = [];
end
