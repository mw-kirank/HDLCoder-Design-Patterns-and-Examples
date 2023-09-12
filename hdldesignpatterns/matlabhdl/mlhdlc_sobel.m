%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sobel Edge Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example shows how to generate HDL code from MATLAB(R) design
% implementing the Sobel edge detection algorithm. The Sobel algorithm is
% implemented by the following steps.
% 
% 1. Compute the horizontal and vertical gradients, gh and gv, by
%    convolving the image with the Sobel kernel and its transpose.
%      Sobel kernel = [ 1  2  1;
%                       0  0  0;
%                      -1 -2 -1 ];
% 2. Compute the gradient of each pixel, g, which is the magnitude of the
%    horizontal and vertical gradients.
%      g = sqrt( gx.^2 + gy.^2 )
% 3. If the gradient is greater than the threshold, the pixel is
%    considered as an edge pixel.
%
% Because the Sobel algorithm includes the convolution of the image with a
% 3-by-3 window, the output will be delayed by a column plus one pixels.
% For example, the algorithm will output the edge for location (2,2) when
% it receives the pixel at location (1,1).
% 
% Note: To simplify design, this example does not have special handling for
% the image border. Therefore, the border of the output is invalid.

%#codegen
% Copyright 2011-2015 The MathWorks, Inc.

function [valid, ed, gh, gv] = mlhdlc_sobel(u)

% Determine whether the output is valid or not.
persistent cnt
if isempty(cnt)
  cnt = 0;
end
cnt = cnt + 1;
valid = cnt > 80+1 && cnt <= 80*80+80+1;

% Delay the input pixel in order to have the pixels in a 3-by-3 window
% centering at the current output location. Let the location for the
% current output pixel be Icc, the pixels in the window are presented as
% follows.
%   [ Ilt  Ict  Irt;
%     Ilc  Icc  Irc;
%     Ilb  Icb  Irb ]

Irb = u;
Irc = filterdelay1(Irb);
Irt = filterdelay2(Irc);
Icb = line_buffer1(Irb);
Icc = filterdelay3(Icb);
Ict = filterdelay4(Icc);
Ilb = line_buffer2(Icb);
Ilc = filterdelay5(Ilb);
Ilt = filterdelay6(Ilc);

% Compute the horizontal and vertical gradients.
gh = Ilt + 2*Ict + Irt - Ilb - 2*Icb - Irb;
gv = Ilt + 2*Ilc + Ilb - Irt - 2*Irc - Irb;

% Compute the square of gradient.
g2 = gh.^2 + gv.^2;

% Determine whether a pixel is on the edge or not.
threshold = 256;
ed = g2 > threshold^2;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line buffer: Delay the image by a column (80 pixels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = line_buffer1(u)
persistent u_d ctr;
if isempty(u_d)
    u_d = zeros(1,80);
    ctr = uint8(1);
end

y = u_d(ctr);
u_d(ctr) = u;

if ctr == uint8(80)
    ctr = uint8(1);
else
    ctr = ctr + 1;
end
end

function y = line_buffer2(u)
persistent u_d ctr;
if isempty(u_d)
    u_d = zeros(1,80);
    ctr = uint8(1);
end

y = u_d(ctr);
u_d(ctr) = u;

if ctr == uint8(80)
    ctr = uint8(1);
else
    ctr = ctr + 1;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delay: Delay the image by a pixel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = filterdelay1(u)
persistent u_d;
if isempty(u_d)
    u_d = 0;
end
y = u_d;
u_d(:) = u;
end

function y = filterdelay2(u)
persistent u_d;
if isempty(u_d)
    u_d = 0;
end
y = u_d;
u_d(:) = u;
end

function y = filterdelay3(u)
persistent u_d;
if isempty(u_d)
    u_d = 0;
end
y = u_d;
u_d(:) = u;
end

function y = filterdelay4(u)
persistent u_d;
if isempty(u_d)
    u_d = 0;
end
y = u_d;
u_d(:) = u;
end

function y = filterdelay5(u)
persistent u_d;
if isempty(u_d)
    u_d = 0;
end
y = u_d;
u_d(:) = u;
end

function y = filterdelay6(u)
persistent u_d;
if isempty(u_d)
    u_d = 0;
end
y = u_d;
u_d(:) = u;
end
