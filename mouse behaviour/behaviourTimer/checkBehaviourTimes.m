function output = checkBehaviourTimes(outputFileName)

ListenChar(2);
WaitSecs(0.2);

%% initialise variables
flag.exptState = 0;    % is the experiment running?
flag.stopExpt = 0;     % changes when the experiment ends
output.times = [];     % times for button presses
output.msg = {};       % states associated with button presses
flag.counter = 1;       % event counter

%%wait for experiment to start
disp('Press space bar to start')

%% main loop
while(true)
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        [output, flag] = checkPress(keyCode, secs, output, flag); 
        WaitSecs(0.2);
    end
    
    if flag.exptState == 0 && flag.stopExpt == 1 %stopped
        break
    end
end

ListenChar(0);

output.times = output.times - output.times(1); % standardise times to the start of the experiment
pauses = strfind(output.msg, 'pauseExpt');

for pause = 1:length(pauses)
    if ~isempty(pauses{pause})
        output.times(pause+1:end) = output.times(pause+1:end) - (output.times(pause+1) - output.times(pause));
    end
end

output.msg = output.msg';
output.times = output.times';

save(outputFileName, 'output');

 