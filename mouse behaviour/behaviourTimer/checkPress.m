function [output, flag] = checkPress(keyCode, secs, output, flag)
keyInd = find(keyCode);
if length(keyInd) == 1
    if keyInd == 44 % spacebar
        
        if flag.counter == 1
            output.msg{flag.counter} = 'startExpt';
            output.times(flag.counter) = secs;
            flag.exptState = 1;
            flag.counter = flag.counter + 1;
            disp('Experiment Commenced');
        elseif flag.exptState == 0
            output.msg{flag.counter} = 'recomExpt';
            output.times(flag.counter) = secs;
            flag.exptState = 1;
            flag.counter = flag.counter + 1;
            disp('Experiment Recommenced');
        elseif flag.exptState == 1
            output.msg{flag.counter} = 'pauseExpt';
            output.times(flag.counter) = secs;
            flag.exptState = 0;
            flag.counter = flag.counter + 1;
            disp('Experiment Paused');
        end
        
    elseif keyInd == 41 % escape key
        
        output.msg{flag.counter} = 'endExpt';
        output.times(flag.counter) = secs;
        flag.exptState = 0;
        flag.stopExpt = 1;
        flag.counter = flag.counter + 1;
        disp('Experiment Ended');
        
    elseif (keyInd ~= 44) && (flag.exptState == 0)
        
        disp('Behaviour was not recorded as experiment has been paused');
        
    elseif (keyInd ~= 44) && (flag.exptState == 1)
        
        switch keyInd
            
            case 15 % L
                output.msg{flag.counter} = 'snfHeadFace';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Sniffing Face/Head');
                
            case 14 % K
                output.msg{flag.counter} = 'snfBdy';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Sniffing Body');
                
            case 13 % J
                output.msg{flag.counter} = 'snfAGT';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Sniffing Ano-genital/Tail');
                
            case 24 % U
                output.msg{flag.counter} = 'mnt';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Mounting');
                
            case 16 % M
                output.msg{flag.counter} = 'bitAtt';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Biting/Attacking');
                
            case 11 % H
                output.msg{flag.counter} = 'chsStk';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Chasing/Stalking');
                
            case 9 % F
                output.msg{flag.counter} = 'grmGen';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Grooming Genitals');
                
            case 7 % D
                output.msg{flag.counter} = 'grmFceBdy';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Grooming Face/Body');
                
            case 21 % R
                output.msg{flag.counter} = 'rtlSnk';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Rattlesnake Tail');
                
            case 22 % S
                output.msg{flag.counter} = 'shvl';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Shovelling');
                
            case 23 % T
                output.msg{flag.counter} = 'other';
                output.times(flag.counter) = secs;
                flag.exptState = 1;
                flag.counter = flag.counter + 1;
                disp('Other Behaviour');
                
            otherwise
                disp('Key not mapped to behaviour');
        end
        
    end
end