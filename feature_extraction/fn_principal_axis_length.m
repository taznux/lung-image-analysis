function p = fn_principal_axis_length(index_list, pixelspacing)
thick = pixelspacing(3);
pixelsize = pixelspacing(1:2);

x = double(index_list);
x(:, 1) = double(x(:, 1)) * pixelsize(1);
x(:, 2) = double(x(:, 2)) * pixelsize(2);
x(:, 3) = double(x(:, 3)) * thick;

for ds = pixelsize : pixelsize : (abs(thick) - pixelsize * 1.5)
    xx = x;
    xx(:, 3) = xx(:, 3) - ds;
    x = [x; xx];
end

[coeff, ~] = pca(x); % variable "score" is not needed.
dirVect = coeff(:, 1); % find the principal axis.

% rotate the nodule so that the principal axis is parallel to z.
rotationsin = dirVect(2) / sqrt(dirVect(1) * dirVect(1) + dirVect(2) * dirVect(2));
rotationcos = dirVect(1) / sqrt(dirVect(1) * dirVect(1) + dirVect(2) * dirVect(2));
xp = x(:, 1) * rotationcos + x(:, 2) * rotationsin;
yp = -x(:, 1) * rotationsin + x(:, 2) * rotationcos;
x(:, 1) = xp;
x(:, 2) = yp;
rotationsin = sqrt(dirVect(1) * dirVect(1) + dirVect(2) * dirVect(2));
rotationcos = dirVect(3);
xp = x(:, 1) * rotationcos - x(:, 3) * rotationsin;
zp = x(:, 1) * rotationsin + x(:, 3) * rotationcos;
x(:, 1) = xp;
x(:, 3) = zp;

p = sort(max(x,[],1) - min(x,[],1));
if isnan(p) | isinf(p)
    p = [0 0 0];
end
end
