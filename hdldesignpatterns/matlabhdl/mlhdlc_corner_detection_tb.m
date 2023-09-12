clear mlhdlc_corner_detection;
clear mlhdlc_sobel;

%   Copyright 2011-2019 The MathWorks, Inc.

image_in = checkerboard(10);
[image_height, image_width] = size(image_in);

% Pre-allocating y for simulation performance
y_cm = zeros(image_height, image_width);
y_ed = zeros(image_height, image_width);
gradient_hori = zeros(image_height,image_width);
gradient_vert = zeros(image_height,image_width);

dataValidOut = y_cm;

idx_in = 1;
idx_out = 1;
for i=1:image_width+3
    for j=1:image_height+3
        if idx_in <= image_width * image_height
            u = image_in(idx_in);
        else
            u = 0;
        end
        idx_in = idx_in + 1;
        
        [valid, ed, gh, gv, cm] = mlhdlc_corner_detection(u);
        
        if valid
            
            y_cm(idx_out) = cm;
            y_ed(idx_out) = ed;
            gradient_hori(idx_out)   = gh;
            gradient_vert(idx_out)   = gv;
            
            idx_out = idx_out + 1;
        end
    end
end

padImage = y_cm;
findLocalMaxima = vision.LocalMaximaFinder('MaximumNumLocalMaxima',100, ...
    'NeighborhoodSize', [11 11], ...
    'Threshold', 0.0005);
Corners = step(findLocalMaxima, padImage);
drawMarkers = vision.MarkerInserter('Size', 2); % Draw circles at corners
ImageCornersMarked = step(drawMarkers, image_in, Corners);

% Display results
% ...
%

nplots = 4;

scrsz = get(0,'ScreenSize');
figure('Name', [mfilename, '_plot'], 'Position',[1 300 700 200])

subplot(1,nplots,1);
imshow(image_in,[min(image_in(:)) max(image_in(:))]);
title('Checker Board')
axis square

subplot(1,nplots,2);
imshow(gradient_hori(3:end,3:end),[min(gradient_hori(:)) max(gradient_hori(:))]);
title(['Vertical',newline,' Gradient'])
axis square

subplot(1,nplots,3);
imshow(gradient_vert(3:end,3:end),[min(gradient_vert(:)) max(gradient_vert(:))]);
title(['Horizontal',newline,' Gradient'])
axis square

% subplot(1,nplots,4);
% imshow(y_ed);
% title('Edges')

subplot(1,nplots,4);
imagesc(ImageCornersMarked)
title('Corners');
axis square
