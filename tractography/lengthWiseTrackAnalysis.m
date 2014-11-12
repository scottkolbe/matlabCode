function meanTrackParam = lengthWiseTrackAnalysis(tracks, data, parameter, method, plotem, fignum)
   
for t = 1:size(tracks.resampData, 2)

    thisTrack = tracks.resampData{t};

    if method == 'interp'
       paramSamp(:,t) = interp3(data, thisTrack(:,2), thisTrack(:,1), thisTrack(:,3)); 
    elseif method == 'nneighbour'
       paramSamp(:,t) = data(round(thisTrack(:,2)), round(thisTrack(:,1)), round(thisTrack(:,3))); 
    end

end

meanTrackParam = mean(paramSamp, 2);
sterrTrackParam = std(paramSamp, [], 2)/(size(paramSamp,2)^0.5);

if plotem
    figure(fignum)
    hold on
    errorbar(1:size(paramSamp,1), meanTrackParam, sterrTrackParam, sterrTrackParam);
    title(parameter)
    hold off
end

