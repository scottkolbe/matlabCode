function [F,X] = ecdf_FA_std(all_FA_img, mask_img)

all_FA = read_avw(all_FA_img);
FA_std = std(all_FA,[],4);
mask = read_avw(mask_img)
for slice=1:size(mask,3)
	
		eroded_mask(:,:,slice) = bwmorph(mask(:,:,slice), 'erode');
	
end
FA_std_eroded = FA_std .* eroded_mask;

non_zeros = find(FA_std_eroded);
FA_std_eroded_vect = FA_std_eroded(non_zeros);
[F,X] = ecdf(FA_std_eroded_vect);