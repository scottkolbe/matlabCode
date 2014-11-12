function [V1_dyad_tensor] = cal_dyad_tensor(V1)

% this function is used to calculate the dyadic tensor of the 
% principal eigen vector from a DTI analysis for use in measuring 
% dyadic coherence after spatial normalisation of a group

% the input 'V1' is the principal eigen vector image (eg the V1 image from FSL)

V1_dyad_tensor = zeros(91,109,91,6);

for ii=1:size(V1,1)
	for jj=1:size(V1,2)
		for kk=1:size(V1,3)
			if(~isempty(V1(ii,jj,kk,:)))
			vect = squeeze(V1(ii,jj,kk,:));
			dyad = vect*vect';
			
			V1_dyad_tensor(ii,jj,kk,1) = dyad(1,1);
			V1_dyad_tensor(ii,jj,kk,2) = dyad(2,2);
			V1_dyad_tensor(ii,jj,kk,3) = dyad(3,3);
			V1_dyad_tensor(ii,jj,kk,4) = dyad(1,2);
			V1_dyad_tensor(ii,jj,kk,5) = dyad(1,3);
			V1_dyad_tensor(ii,jj,kk,6) = dyad(2,3);
			end
		end
	end
end
