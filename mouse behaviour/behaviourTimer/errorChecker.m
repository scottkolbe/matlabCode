function [output, flag] = errorChecker(output, flag)
if flag.exptState == 0
    if flag.stopExpt == 1
        disp('Finishing Experiment\n');
        
    elseif flag.stopExpt == 0
        disp('Something is wrong, stopping experiment\n')
        
    end
end