FRAMES = 1;
WIDTH = 752;
HEIGHT = 480;
HBLANK = 10;%748;
VBLANK = 10;%120;

%   Copyright 2011-2019 The MathWorks, Inc.

vidData = double(imread('mlhdlc_img_yuv.png'));

for f = 1:FRAMES
    vidOut = zeros(HEIGHT, WIDTH, 3);
    
    for y = 0:HEIGHT+VBLANK-1
        for x = 0:WIDTH+HBLANK-1
            if y >= 0 && y < HEIGHT && x >= 0 && x < WIDTH
                b = vidData(y+1,x+1,1);
                g = vidData(y+1,x+1,2);
                r = vidData(y+1,x+1,3);
            else
                b = 0; g = 0; r = 0;
            end           

            [xOut, yOut, yData, uData, vData] = ...
                mlhdlc_rgb2yuv(x, y, r, g, b);

            if yOut >= 0 && yOut < HEIGHT && xOut >= 0 && xOut < WIDTH
                vidOut(yOut+1,xOut+1,:) = [yData vData uData];
            end     
        end  
    end
    
    figure(1);
    subplot(1,2,1); 
    imshow(uint8(vidData));
    subplot(1,2,2); 
    imshow(ycbcr2rgb(uint8(vidOut)));
    drawnow;                
end
