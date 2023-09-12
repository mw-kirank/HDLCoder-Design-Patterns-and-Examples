%Test bench for scaling, analogous to automatic gain control (AGC)

%   Copyright 2011-2018 The MathWorks, Inc.

testFile = 'mlhdlc_img_peppers.png';
imgOrig = imread(testFile);
[height, width] = size(imgOrig);
imgOut = zeros(height,width);
hBlank = 20;
% make sure we have enough vertical blanking to filter the histogram
vBlank = ceil(2^14/(width+hBlank));

%df - Temporal damping factor of rescaling
%dr - Desired output dynamic range
df = 0; 
dr = 255; 
nrOfOutliers = 248;
maxGain = 2*2^4;

for frame = 1:2
    disp(['frame: ', num2str(frame)]);
    for y_in = 0:height+vBlank-1       
        %disp(['frame: ', num2str(frame), ' of 2, row: ', num2str(y_in)]);
        for x_in = 0:width+hBlank-1
            if x_in < width && y_in < height
                pixel_in = double(imgOrig(y_in+1, x_in+1));
            else
                pixel_in = 0;
            end
            
            [x_out, y_out, pixel_out] = ...
                mlhdlc_image_scale(x_in, y_in, pixel_in, df, dr, ...
                    nrOfOutliers, maxGain, width, height);
                       
            if x_out < width && y_out < height
                imgOut(y_out+1,x_out+1) = pixel_out;
            end
        end
    end
    
    figure('Name', [mfilename, '_scale_plot']);
    imgOut = round(255*imgOut/max(max(imgOut)));
    subplot(2,2,1); imshow(imgOrig, []);
    title('Original Image');
    subplot(2,2,2); imshow(imgOut, []);
    title('Scaled Image');
    subplot(2,2,3); histogram(double(imgOrig(:)),2^14-1);
    axis([0, 255, 0, 1500]);
    title('Histogram of original Image');
    subplot(2,2,4); histogram(double(imgOut(:)),2^14-1);
    axis([0, 255, 0, 1500]);
    title('Histogram of equalized Image');
end