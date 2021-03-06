function createEVFiles(ev)

% PSPS
saveVar = ev.pspstargOnsetTime{1};
if ~isempty(saveVar)
    save('run1PSPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1PSPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.pspstargOnsetTime{2};
if ~isempty(saveVar)
    save('run2PSPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2PSPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.pspstargOnsetTime{3};
if ~isempty(saveVar)
    save('run3PSPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3PSPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.pspstargOnsetTime{4};
if ~isempty(saveVar)
    save('run4PSPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4PSPS.txt', 'saveVar', '-ASCII');
end

% ASPS
saveVar = ev.aspstargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ASPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1ASPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.aspstargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ASPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2ASPS.txt', 'saveVar', '-ASCII');
    
end
saveVar = ev.aspstargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ASPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3ASPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.aspstargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ASPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4ASPS.txt', 'saveVar', '-ASCII');
end

% ErrPS
saveVar = ev.errpstargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ERRPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1ERRPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.errpstargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ERRPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2ERRPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.errpstargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ERRPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3ERRPS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.errpstargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ERRPS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4ERRPS.txt', 'saveVar', '-ASCII');
end

% ASAS
saveVar = ev.asastargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ASAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1ASAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asastargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ASAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2ASAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asastargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ASAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3ASAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asastargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ASAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4ASAS.txt', 'saveVar', '-ASCII');
end

% PSAS
saveVar = ev.psastargOnsetTime{1};
if ~isempty(saveVar)
    save('run1PSAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1PSAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psastargOnsetTime{2};
if ~isempty(saveVar)
    save('run2PSAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2PSAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psastargOnsetTime{3};
if ~isempty(saveVar)
    save('run3PSAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3PSAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psastargOnsetTime{4};
if ~isempty(saveVar)
    save('run4PSAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4PSAS.txt', 'saveVar', '-ASCII');
end

% ErrAS
saveVar = ev.errastargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ERRAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1ERRAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.errastargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ERRAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2ERRAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.errastargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ERRAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3ERRAS.txt', 'saveVar', '-ASCII');
end
saveVar = ev.errastargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ERRAS.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4ERRAS.txt', 'saveVar', '-ASCII');
end

% PSDirErr
saveVar = ev.psDirErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1PSDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1PSDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psDirErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2PSDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2PSDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psDirErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3PSDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3PSDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psDirErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4PSDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4PSDir.txt', 'saveVar', '-ASCII');
end

% ASDirErr
saveVar = ev.asDirErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ASDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1ASDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asDirErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ASDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2ASDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asDirErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ASDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3ASDir.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asDirErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ASDir.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4ASDir.txt', 'saveVar', '-ASCII');
end

% PSOtherErr
saveVar = ev.psOtherErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1PSErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1PSErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psOtherErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2PSErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2PSErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psOtherErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3PSErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3PSErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.psOtherErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4PSErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4PSErr.txt', 'saveVar', '-ASCII');
end

% ASOtherErr
saveVar = ev.asOtherErrortargOnsetTime{1};
if ~isempty(saveVar)
    save('run1ASErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1ASErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asOtherErrortargOnsetTime{2};
if ~isempty(saveVar)
    save('run2ASErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2ASErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asOtherErrortargOnsetTime{3};
if ~isempty(saveVar)
    save('run3ASErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3ASErr.txt', 'saveVar', '-ASCII');
end
saveVar = ev.asOtherErrortargOnsetTime{4};
if ~isempty(saveVar)
    save('run4ASErr.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4ASErr.txt', 'saveVar', '-ASCII');
end

% Eye Speed
saveVar = ev.eye{1};
if ~isempty(saveVar)
    save('run1Eye.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run1Eye.txt', 'saveVar', '-ASCII');
end
saveVar = ev.eye{2};
if ~isempty(saveVar)
    save('run2Eye.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run2Eye.txt', 'saveVar', '-ASCII');
end
saveVar = ev.eye{3};
if ~isempty(saveVar)
    save('run3Eye.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run3Eye.txt', 'saveVar', '-ASCII');
end
saveVar = ev.eye{4};
if ~isempty(saveVar)
    save('run4Eye.txt', 'saveVar', '-ASCII');
else
    saveVar =[0 0 0];
    save('run4Eye.txt', 'saveVar', '-ASCII');
end
