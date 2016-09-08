function [area, perimeter, r, compact, var_n, hist_n] = fn_shape_feature(T, pixelsize)

se = strel('disk',1);

area=0;
perimeter=0;
r=0;
compact=0;
var_n=0;

R = (imresize(T,2)>0.5);
I = zeros(size(R)+4);
I(3:end-2,3:end-2) = R;
B = imdilate(I,se) - I;

[row, col] = size(I);


%     if row < 4 | col < 4
%         return;
%     end

cy = row/2;
cx = col/2;

[ynum, xnum] = find(B == 1);
bound_points = [ynum, xnum];

if(sum(size(bound_points)) < 2)
    return;
end

area = sum(I(:))/4*pixelsize(1)*pixelsize(1);
perimeter = sum(B(:))/2*pixelsize(1);

delta = ([(bound_points(:,1) - cy) (bound_points(:,2) - cx)]).^2;
dist = sqrt(sum(delta,2))/2*pixelsize(1);

r = mean(dist);

%compact = area/(pi*r^2);
compact = 4*pi*area/(perimeter)^2;

ndist = dist/r;

var_n = var(ndist);


ndist(ndist <0.5) = 0.5;
ndist(ndist >1.5) = 1.5;

[hist_n, ~] = hist(ndist,0.5:0.1:1.5);



%sum(dist-r)/r/perimeter;

%[area, perimeter, r, compact var(n)]

%figure, imshow(T,[]);

end


