
%

%   Copyright 2011-2015 The MathWorks, Inc.

clear mlhdlc_2DFIR;
TOL = 1e-6;

% Read the image
image_in = double(imread('mlhdlc_cameraman.png'));
H = fspecial('unsharp');

% Pad the image
[rows, pixels] = size(image_in);
pad_vert_im = [ zeros(1,pixels);zeros(1,pixels);image_in;...
    zeros(1,pixels);zeros(1,pixels)];
pad_horiz_im = [ zeros(rows+4,2) pad_vert_im zeros(rows+4,2)];

% Reshape the image as a vector
[rows, pixels] = size(pad_horiz_im);
image_vector_length = rows*pixels;
image_in_vector = reshape(pad_horiz_im',1,image_vector_length);

% Pre-allocating y for simulation performance
y = zeros(1,length(image_in_vector));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streaming loop calling the design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(image_in_vector)
    
    y(i) = mlhdlc_2DFIR(image_in_vector(i));
end

% Reshape the output back to a 2D matrix
image_out = reshape(y,pixels,rows)';


filt_image = imfilter(image_in,H,0);
err = filt_image-image_out(4:end-1,4:end-1);
err = (err > TOL) .* err;

figure('Name', [mfilename, '_plot']);
subplot(1,2,1);
imshow(int8(image_out(4:end-1,4:end-1)));title('HDL Output');
subplot(1,2,2);
imshow(err);title('Difference');