%% script to locate theshold using 2 sample gaussian mixture model
warning('off', 'all');
FSdir = getenv('FREESURFER_HOME');
path(path, [FSdir '/matlab']);

img = MRIread('fast_flair_seg_0_values.nii.gz');
voxVals = reshape(img.vol, size(img.vol, 1)*size(img.vol, 2)*size(img.vol, 3), 1);
Y = sort(voxVals(voxVals > 5));
s = zeros(length(Y), 1);
s(round(length(Y)*0.75):end) = 1;
s = s+1;

for ii = 1:100
    obj = gmdistribution.fit(Y,2,'Start',s);
    [~,I] = min(obj.mu);
    threshold(ii) = Y(round(length(Y)*obj.PComponents(I)));
end
threshold = median(threshold);

save('threshold', 'threshold', '-ASCII');