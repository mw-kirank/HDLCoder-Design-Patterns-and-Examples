
%

%   Copyright 2011-2015 The MathWorks, Inc.

% clear the design function state
clear mlhdlc_sobel

checker = double(checkerboard(10)*255);
[image_height, image_width] = size(checker);

% Pre-allocating y for simulation performance
gradient_hori = zeros(image_height,image_width);
gradient_vert = zeros(image_height,image_width);
y = zeros(image_height,image_width);

idx_in = 1;
idx_out = 1;
for i=1:image_width+1
    for j=1:image_height+1
        if idx_in <= image_width * image_height
            u = checker(idx_in);
        else
            % Because the Sobel algorithm has a delay, we need to continue
            % calling the algorithm with garbage input until we have all of
            % the valid outputs. 
            u = 0;
        end
        idx_in = idx_in + 1;
        
        [valid, ed, gh, gv] = mlhdlc_sobel(u);
        
        if valid
          gradient_hori(idx_out) = gh;
          gradient_vert(idx_out) = gv;
          y(idx_out) = ed;
          idx_out = idx_out + 1;
        end
    end
end

scrsz = get(0,'ScreenSize');
figure('Name', [mfilename, '_plot'], 'Position',[1 300 700 200])
subplot(1,4,1);
imshow(checker,[min(checker(:)) max(checker(:))]);
title('Checker Board')
subplot(1,4,2);
imshow(gradient_hori(3:end,3:end),[min(gradient_hori(:)) max(gradient_hori(:))]);
title('Vertical Gradient')
subplot(1,4,3);
imshow(gradient_vert(3:end,3:end),[min(gradient_vert(:)) max(gradient_vert(:))]);
title('Horizontal Gradient')
subplot(1,4,4);
imshow(y);
title('Edges')
