%% script to locate theshold using 2 sample gaussian mixture model

FSdir = getenv('FREESURFER_HOME');
path(path, [FSdir '/matlab']);

img = MRIread('flair_seg_brain_values.nii.gz');
voxVals = reshape(img.vol, size(img.vol, 1)*size(img.vol, 2)*size(img.vol, 3), 1);
Y = sort(voxVals(voxVals > 5));
S.mu = [Y(round(length(Y)*0.25)) Y(round(length(Y)*0.75))];
S.sigma = [50 50];
S.PComponents = [0.5 0.5];

for ii = 1:100
    obj = gmdistribution.fit(Y,2);
    [~,I] = min(obj.mu);
    threshold(ii) = Y(round(length(Y)*obj.PComponents(I)));
end
threshold = median(threshold);

save('threshold', 'threshold', '-ASCII');