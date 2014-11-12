function h=MI2(image_1,image_2,method)
% function h=MI2(image_1,image_2,method)
%
% Takes a pair of images and returns the mutual information Ixy using joint entropy function JOINT_H.m
% 
% written by http://www.flash.net/~strider2/matlab.htm


a=joint_h(image_1,image_2); % calculating joint histogram for two images
[r,c] = size(a);
b= a./(r*c); % normalized joint histogram
y_marg=sum(b); %sum of the rows of normalized joint histogram
x_marg=sum(b');%sum of columns of normalized joint histogran

Hy=0;
for i=1:c;    %  col
      if( y_marg(i)==0 )
         %do nothing
      else
         Hy = Hy + -(y_marg(i)*(log2(y_marg(i)))); %marginal entropy for image 1
      end
   end
   
Hx=0;
for i=1:r;    %rows
   if( x_marg(i)==0 )
         %do nothing
      else
         Hx = Hx + -(x_marg(i)*(log2(x_marg(i)))); %marginal entropy for image 2
      end   
   end
h_xy = -sum(sum(b.*(log2(b+(b==0))))); % joint entropy

if method=='Normalized';
h = (Hx + Hy)/(2*h_xy);% Mutual information
else
h = Hx + Hy - h_xy;% Mutual information
end


function h=joint_h(image_1,image_2)
% function h=joint_h(image_1,image_2)
%
% takes a pair of images of equal size and returns the 2d joint histogram.
% used for MI calculation
% 
% written by http://www.flash.net/~strider2/matlab.htm


rows=size(image_1,1);
cols=size(image_1,2);
N=256;

h=zeros(N,N);

for i=1:rows;    %  col 
  for j=1:cols;   %   rows
    h(image_1(i,j)+1,image_2(i,j)+1)= h(image_1(i,j)+1,image_2(i,j)+1)+1;
  end
end