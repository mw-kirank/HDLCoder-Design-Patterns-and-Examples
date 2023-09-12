%Test bench for Histogram Equalization

%   Copyright 2011-2018 The MathWorks, Inc.

testFile = 'mlhdlc_img_peppers.png';
imgOrig = imread(testFile);
[height, width] = size(imgOrig);
imgOut = zeros(height,width);
hBlank = 20;
% make sure we have enough vertical blanking to filter the histogram
vBlank = ceil(2^14/(width+hBlank));

for frame = 1:2
    disp(['working on frame: ', num2str(frame)]);
    for y_in = 0:height+vBlank-1
        %disp(['frame: ', num2str(frame), ' of 2, row: ', num2str(y_in)]);
        for x_in = 0:width+hBlank-1
            if x_in < width && y_in < height
                pixel_in = double(imgOrig(y_in+1, x_in+1));
            else
                pixel_in = 0;
            end
            
            [x_out, y_out, pixel_out] = ...
                mlhdlc_heq(x_in, y_in, pixel_in, width, height);
                       
            if x_out < width && y_out < height
                imgOut(y_out+1,x_out+1) = pixel_out;
            end
        end
    end
    
    % normalize image to 255
    imgOut = round(255*imgOut/max(max(imgOut)));
    
    figure(1)
    subplot(2,2,1); imshow(imgOrig, [0,255]);
    title('Original Image');
    subplot(2,2,2); imshow(imgOut, [0,255]);
    title('Equalized Image');
    subplot(2,2,3); histogram(double(imgOrig(:)),2^14-1);
    axis([0, 255, 0, 1500])
    title('Histogram of original Image');
    subplot(2,2,4); histogram(double(imgOut(:)),2^14-1);
    axis([0, 255, 0, 1500])
    title('Histogram of equalized Image');
end
