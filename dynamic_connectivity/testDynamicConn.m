clear


%% toy example using synthesised data
% x = [1:400]';
% noise1 = rand(length(x), 1);
% noise2 = rand(length(x), 1);
% sig1 = x .* noise1;
% sig2 = x .* noise2;
% y1 = sin(sig1);
% y2 = sin(sig2);

%% using MRI timeseries from two single voxels
img = MRIread('raw_data_lowpass.nii.gz');

y1 = squeeze(img.vol(75,50,55,:));
y1 = y1-mean(y1);
y1 = y1(1:400);
y2 = squeeze(img.vol(75,55,55,:));
y2 = y2-mean(y2);
y2 = y2(1:400);

%% plot signals
figure(1)
subplot(2,1,1)
plot(y1)
hold on
plot(y2, 'r')
hold off

%% define weight vector
dt = 20; % window
theta = 7; % exponent
w = expweights(dt, theta); % get weights
posW = flipud(w);
negW = w;

%% perform weighted correlation between signals
for yy = 1:length(y1)
    % this if statement sets up the weights and data to deal with clipped ends
    if yy == 1
        wToUse =[negW(end); posW];
        dataToUse = [y1(1:length(posW)+1) y2(1:length(posW)+1)];
    elseif yy < length(negW)+1
        wToUse =[negW(end-yy+2:end); negW(end); posW];
        dataToUse = [y1(1:yy+length(posW)) y2(1:yy+length(posW))];
    elseif yy > length(y1)-length(posW)-1
        wToUse =[negW; negW(end);posW(1:length(y1)-yy)];
        dataToUse = [y1(yy-length(negW):end) y2(yy-length(negW):end)];
    elseif yy == length(y1)
        wToUse =[negW;negW(end)];
        dataToUse = [y1(end-length(posW):end) y2(end-length(posW):end)];
    else
        wToUse = [negW;negW(end);posW];
        dataToUse = [y1(yy-length(negW):yy+length(posW)) y2(yy-length(negW):yy+length(posW))];
    end
    
    R = weightedcorrs(dataToUse, wToUse); % calculate R 
    weightedRall(yy) = R(2);
end

%% plot correlation vector
subplot(2,1,2)
plot(weightedRall)
ylim([-1 1])