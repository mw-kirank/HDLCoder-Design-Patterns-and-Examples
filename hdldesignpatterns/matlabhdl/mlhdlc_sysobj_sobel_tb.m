
%

%   Copyright 2011-2015 The MathWorks, Inc.

image_in = double(imread('mlhdlc_img_stop_sign.gif'));
[rows, pixels] = size(image_in);
image_vector_length = rows*pixels;
image_in_vector = reshape(image_in',1,image_vector_length);


% Pre-allocating y for simulation performance
y = zeros(1,length(image_in_vector));


for i = 1:length(image_in_vector)
    [~, ~, y(i)] = mlhdlc_sysobj_sobel(image_in_vector(i));
end

% Reshape output back to 2D array
image_out = reshape(y,pixels,rows)';

% Display results
figure('Name', [mfilename, '_plot']);
subplot(1,2,1)
imagesc(image_in), colormap('gray')
subplot(1,2,2)
imagesc(image_out), colormap('gray')

