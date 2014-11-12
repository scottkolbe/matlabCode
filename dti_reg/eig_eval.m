function [eigs] = eig_eval(tensor_img)

%% First we need to find out how many of the gradient
%% directions are all zero...


tensor = read_avw(tensor_img);

eigs = zeros(size(tensor,1),size(tensor,2),size(tensor,3),3);

for ii=1:size(tensor,1)
	for jj=1:size(tensor,2)
		for sl=1:size(tensor,3)

			tv = squeeze( tensor(ii,jj,sl,:) );

			if( ~isempty(tv))

				TV=zeros(3,3);
				TV(1,1) = tv(1); TV(2,2) = tv(2); TV(3,3) = tv(3);
				TV(1,2) = tv(4); TV(2,1) = tv(4);
				TV(1,3) = tv(5); TV(3,1) = tv(5);
				TV(2,3) = tv(6); TV(3,2) = tv(6);


				[U,S,V] = svd(TV);

				
				eigs(ii,jj,sl) = U(1:3,1);
			else
				eigs(ii,jj,sl) = [0 0 0]';
			end
		end
	end
		
end
