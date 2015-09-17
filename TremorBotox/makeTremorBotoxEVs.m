function makeTremorBotoxEVs(JoyStickFile, outputDir)

try
    %% Read in CSV file and convert to table
    filename = JoyStickFile;
    delimiter = ',';
    startRow = 6;
    formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);
    JS = table(dataArray{1:end-1}, 'VariableNames', {'ts','WallHits','BallMisses','GameRunning','LeftRightAxis','ForwardBackwardAxis','TwistAxis','Trial','Block','xPaddle','yPaddle','xBlueBall','yBlueBall','xRedBall','yRedBall','Trigger'});
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    %% make EV for each Block
    JS.int = JS.ts-[0;JS.ts(1:end-1)];
    uniqBlocks = unique(JS.Block);
    if length(uniqBlocks) == 6
        
        EVname{1} = 'Move';
        EVname{2} = 'Watch';
        EVname{3} = 'Play';
        EVname{4} = 'MoveCue';
        EVname{5} = 'WatchCue';
        EVname{6} = 'PlayCue';
        
        for block = 1:length(uniqBlocks)
            A = JS.ts(JS.Block == uniqBlocks(block));
            B = [JS.int(JS.Block == uniqBlocks(block)) ones(length(A),1)];
            C = [A B];
            save([outputDir '/' EVname{block} '.txt'], 'C', '-ascii')
        end
        
        %% make EV for joystick position
        D = [JS.xPaddle JS.int ones(length(JS.int), 1)];
        save([outputDir '/JSxpos.txt'], 'D', '-ascii')
        
    else
        disp('Error, cannot identify all contrasts')
        
    end
    
catch
    
end
