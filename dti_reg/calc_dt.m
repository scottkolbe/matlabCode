function calc_dt
% taken from Kingsley, Concepts in MR, 2005, page 157

% load data struct
load('diffusion_data.mat');

bvecs = diffusion_data.b(:,11:70)';
B0 = diffusion_data.B0;
B1 = double(diffusion_data.B1);
threshold = 40;
b_val = 1000;

% setup H matrix

H = ones(size(bvecs,1),6);

for ii=1:size(bvecs,1)

	H(ii,:) = [ bvecs(ii,:).*bvecs(ii,:) ...
                              2*bvecs(ii,1).*bvecs(ii,2) ...
                              2*bvecs(ii,1).*bvecs(ii,3) ...
                              2*bvecs(ii,2).*bvecs(ii,3) ];
end

% Y = Hd
% where Yi = (log(So/Si))/bval
% 
% solve d for each Y (voxel)

D = zeros([size(B0) 6]);
Eigvals = zeros([size(B0) 3]);


for ii=1:size(B1,1)
    for jj=1:size(B1,2)
        for kk=1:size(B1,3)
            
            if(~isempty(B0(ii,jj,kk)) & B0(ii,jj,kk) > threshold)
                            
                Yi = squeeze((log(B0(ii,jj,kk) ./ B1(ii,jj,kk,:)))/b_val);
                Yi( isinf(Yi) ) = 0;
                d = Yi'/H';
                D(ii,jj,kk,:) = d;
            
                TV=zeros(3,3);
				TV(1,1) = d(1); TV(2,2) = d(2); TV(3,3) = d(3);
				TV(1,2) = d(4); TV(2,1) = d(4);
				TV(1,3) = d(5); TV(3,1) = d(5);
				TV(2,3) = d(6); TV(3,2) = d(6);
            
                [U,S,V] = svd(TV);

				Eigvals(ii,jj,kk,:) = diag(S);
				               
            else
                D(ii,jj,kk,:) = [0 0 0 0 0 0];
                Eigvals(ii,jj,kk,:) = [0 0 0];
            end
            
        end
    end
end

tensor=struct('D',{D}, 'E',{Eigvals});

save('tensor.mat','tensor');
end
