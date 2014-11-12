function createEVFiles(ev)

% save text files
saveVar = ev.ps.targOnsetTime{1};
if ~isempty(saveVar)
    save('run1PS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.targOnsetTime{2};
if ~isempty(saveVar)
    save('run2PS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.targOnsetTime{3};
if ~isempty(saveVar)
    save('run3PS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.targOnsetTime{4};
if ~isempty(saveVar)
    save('run4PS.txt', 'saveVar', '-ASCII');
end

saveVar = ev.as.targOnsetTime{1};
if ~isempty(saveVar)
    save('run1AS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.targOnsetTime{2};
if ~isempty(saveVar)
    save('run2AS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.targOnsetTime{3};
if ~isempty(saveVar)
    save('run3AS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.targOnsetTime{4};
if ~isempty(saveVar)
    save('run4AS.txt', 'saveVar', '-ASCII');
end

saveVar = ev.ps.DirErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1PSDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.DirErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2PSDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.DirErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3PSDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.DirErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4PSDir.txt', 'saveVar', '-ASCII');
end

saveVar = ev.as.DirErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ASDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.DirErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ASDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.DirErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ASDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.DirErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ASDir.txt', 'saveVar', '-ASCII');
end

saveVar = ev.ps.OtherErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1PSErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.OtherErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2PSErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.OtherErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3PSErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.ps.OtherErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4PSErr.txt', 'saveVar', '-ASCII');
end

saveVar = ev.as.OtherErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ASErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.OtherErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ASErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.OtherErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ASErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.as.OtherErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ASErr.txt', 'saveVar', '-ASCII');
end

saveVar = ev.eye{1};
if ~isempty(saveVar)
    save('run1Eye.txt', 'saveVar', '-ASCII');
end
saveVar = ev.eye{2};
if ~isempty(saveVar)
    save('run2Eye.txt', 'saveVar', '-ASCII');
end
saveVar = ev.eye{3};
if ~isempty(saveVar)
    save('run3Eye.txt', 'saveVar', '-ASCII');
end
saveVar = ev.eye{4};
if ~isempty(saveVar)
    save('run4Eye.txt', 'saveVar', '-ASCII');
end
