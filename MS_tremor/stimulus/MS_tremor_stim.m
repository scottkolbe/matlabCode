function [stim,jstk] = MS_tremor_stim(saveDir,subjid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI stimulus function for MS tremor study

% TO DO:
% 1) define stimulus using cosine function for simple harmonic motion
% 2) make functions for drawing lines on the screen for stimulus and
% joystick position
% 3) get Screen function working for a VGA screen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main command loop
try
    while flag.stop~=1 && stim.thisTrial<stim.nTrials, % loop through trials
        [stim,jstk,flag,scr] = MS_tremor_stim_runTrial(stim,jstk,flag,scr);
        flag.thisTrial = flag.thisTrial+1;
    end
    MS_tremor_stim_Save(stim,jstk,flag,scr,subjid); % save results
catch err
    % close the Onscreen Window if there was an error
    Screen('CloseAll');
    commandwindow;
    MS_tremor_stim_Error(err);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [stim,jstk,flag] = MS_tremor_stim_initialise(stim,jstk,flag)

% initialise screen
scr.viewDist = 700; %screen viewing distance in mm
scr.colBG = [255 255 255]; %100 100 100
screenNumber=max(Screen('Screens'));
[scr.w, scr.rect]=Screen('OpenWindow', screenNumber, scr.colBG,[],32,2);
scr.width = scr.rect(2)-scr.rect(1);
scr.height = scr.rect(4)-scr.rect(3);
Screen(scr.w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
scr.vbl=Screen('Flip', scr.w);
HideCursor;
scr.black = BlackIndex(scr.w);
scr.white = WhiteIndex(scr.w);
[scr.cent(1), scr.cent(2)] = RectCenter(scr.rect);
scr.fps=Screen('FrameRate',scr.w);      % frames per second
scr.ifi=Screen('GetFlipInterval', scr.w);
if scr.fps==0
    scr.fps=1/scr.ifi;
end;
scr.ppd = pi * (scr.rect(3)-scr.rect(1)) / atan(scr.width/scr.viewDist/2) / 360; % pixels per degree

% imaging parameters
stim.tr = 1.4;

% overall stimulus parameters
stim.type = {'Follow Eyes','Follow with Joystick','Follow with Joystick Inverted'}; %block types
stim.cueTime = 3; %3second cue and countdown for each block
stim.id = [1 2 3];
stim.time = [20 20 20]; %block lengths (TRs)
stim.repeats = [4 4 4];
stim.oscil = [30 30 30];
stim.allTrialIds = [];
stim.duration = [];
for ii = 1:length(stim.id)
    stim.allTrialIds = [stim.alltrialIds; repmat(stim.id(ii),stim.repeats(ii),1)];
    stim.duration = [stim.duration; repmat(stim.time(ii),stim.repeats(ii),1)];
end
stim.nTrials = length(stim.allTrialIds); %total number of trials
stim.order = randperm(stim.nTrials); %trial order vector - unique for each experiment
stim.allTrialIds = stim.allTrialIds(stim.order); %stim types in order
stim.duration = stim.duration(stim.order); %stim durations in order

% joystick parameters and output variables
jstk.tres = 0.5*scr.ifi; %joystick sampling freq (ms)
jstk.numSamps = (stim.tr*sum(stim.duration))/jstk.tres;
jstk.sampTime = 0:jstk.tres:(jstk.tres*jstk.numSamps-jstk.tres); %time from beginning of expt
jstk.tSamps = zeros(size(jstk.sampTime)); %actual timeStamps from GetSecs
jstk.currSamp = 0;


% define screen positions for stimulus based on cos function


% initialise joystick outputs
jstk.gamepadName = Gamepad('GetGamepadNamesFromIndices', 1); %HID name
jstk.numButtons = Gamepad('GetNumButtons', 1); %number of buttons
jstk.numAxes = Gamepad('GetNumAxes', 1); %number of joystick axes
jstk.xpos = zeros(jstk.numSamps,1); %xpos output
jstk.ypos = zeros(jstk.numSamps,1); %ypos output
jstk.msg = cell(jstk.numSamps,1);

% initialise flags
flag.start = 0; %start of experiment
flag.stop = 0; %stop experiment
flag.error = 0; %error detected
flag.trigger = 0;
flag.thisTrial = 0;
flag.currTime = getSecs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [stim,jstk,flag] = MS_tremor_stim_runTrial(stim,jstk,flag)

% if trial 0 then display wait command to subject until MRI trigger is
% received
if flag.thisTrial==0 
    while flag.start==0 && flag.stop~=0
        % display wait message
        text='Waiting for scanner to start, hold joystick';
        Screen('DrawText',scr.w,text,scr.centre(1),scr.centre(2),[0 0 0],[0.5 0.5 0.5])
        Screen('TextSize', scr.w,10);
        Screen('DrawingFinished', scr.w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
        scr.vbl=Screen('Flip', scr.w, scr.vbl + 0.5*scr.ifi);
        % check for MRI trigger
        [flag,stim] = CheckKeys(flag,stim);
        if flag.trigger==1
            flag.start=1;
        end
    end
    % reset trigger flag, sample joystick and commence experiment
    flag.trigger = 0;
    jstk.currSamp = 1;
    msg = 'startExpt';
    jstk = sampleJstk(jstk,flag,msg);
    flag.currTime = GetSecs;
    
elseif flag.thisTrial~=0 && flag.thisTrial<=nTrials
    
    thisTrialType = stim.allTrialIds(flag.thisTrial);
    flag.blockStartTime = flag.currTime;
    
    % start stimulus block
    while flag.currTime<flag.blockStartTime+(stim.duration(stim.thisTrial))
        % cue with count down
        ii = 1;
        flag.cueStart=flag.currTime;
        while flag.currTime<flag.cueStart+(stim.cueTime/3)
            if ii==1
                text='3';
            elseif ii==2
                text='2';
            elseif ii==3
                text='1';
            end
            Screen('DrawText',scr.w,text,scr.centre(1),scr.centre(2),[0 0 0],[0.5 0.5 0.5])
            Screen('TextSize', scr.w,10);
            Screen('DrawingFinished', scr.w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
            msg = ['Cueing for Block' num2str(flag.thisTrial)];
            jstk = sampleJstk(jstk,flag,msg); 
            scr.vbl=Screen('Flip', scr.w, scr.vbl + 0.5*scr.ifi);
            flag.currTime = getSecs;
        end                
        
        % loop for each joystick sample
        while flag.start==0 && flag.stop~=0 && flag.currTime<jstk.tSamps(1)+0.5*scr.ifi
            % display trial type on screen
            
            % display stimulus
            flag.thisStimX = ;
            stim = plotLine(stim); %display stimulus line
            
            % stimulus type determines whether the joystick line is plotted
            % and in what position (correct or inverted)
            if thisTrialType == 1
                % don't display joystick
            elseif thisTrialType == 2
                % display joystick
                jstk = sampleJstk(jstk,flag,msg);
                stim = plotLine(stim); %display joystick line
            elseif thisTrialType == 3
                % display inverted joystick position
                jstk = sampleJstk(jstk,flag,msg);
                stim = plotLine(stim); %display joystick line
            end
            
            % check for keypress
            [flag,stim] = CheckKeys(flag,stim);
            if flag.trigger==1
                %put this time in a variable
            end
            if flag.stop == 1
                %end experiment
            end
            %update time stamp
            
            Screen('DrawingFinished', scr.w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
            scr.vbl = Screen('Flip', scr.w, scr.vbl + 0.5*scr.ifi);
            flag.currTime = GetSecs;
        end
        jstk.tSamps(jstk.currSamp)=flag.currTime; %save current joystick location
        jstk.currSamp = jstck.currSamp+1; %iterate sample
    end
    
else
    err.msg = 'Error: Trying to perform more stimulus blocks than expected!!!';
    MS_tremor_stim_Error(err)
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jstk = sampleJstk(jstk,flag,msg)

jstk.tSamps(jstk.currSamp) = flag.currTime;
ax1 = Gamepad('GetAxis', 1, 1);
ax2 = Gamepad('GetAxis', 1, 2);
jstk.xpos(jstk.currSamp) = (ax1-AxisMin)/(AxisMax-AxisMin)*scr.width;
jstk.ypos(jstk.currSamp) = (ax2-AxisMin)/(AxisMax-AxisMin)*scr.height;
jstk.msg{jstk.currSamp} = msg;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stim = plotLine(stim,jstck,scr,flag)

if flag.drawType == 0 %stimulus
    x = flag.thisStimX;
    Screen('DrawLines', scr.w, [x scr.cent(2)], 2, 'r');
elseif flag.drawType == 1 %joystick
    x = jstk.xpos(jstk.currSamp);
    Screen('DrawLines', scr.w, [x scr.cent(2)], 2, 'k');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MS_tremor_stim_Save(stim,jstk,flag,scr,saveDir,subjid)

% close screen, stop recording and save data
Screen('CloseAll')
save([saveDir subjid '_jstkExpt.mat'],stim,flag,scr)
ShowCursor
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MS_tremor_stim_Error(err)

disp(err.msg)
Screen('CloseAll')
ShowCursor
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = CheckKeys(flag)

[~,~,keyCode] = KbCheck;
k = find(keyCode,1);
if isempty(k), return; end
switch k
    case {KbName('ESCAPE')} % quit
        flag.stop = 1;
    case {KbName('^')} % MRI trigger
        flag.trigger = 1;
    otherwise
        
end
end