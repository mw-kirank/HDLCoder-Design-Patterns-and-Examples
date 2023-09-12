
%

%   Copyright 2013-2015 The MathWorks, Inc.

% Clean screen and memory 
close all
clear mlhdlc_hdr
set(0,'DefaultFigureWindowStyle','docked')


%% Read the two exposed images

short = imread('mlhdlc_hdr_short.png');
long = imread('mlhdlc_hdr_long.png');

% define HDR output variable
HDR = zeros(size(short));
[height, width, color] = size(HDR);

figure('Name', [mfilename, '_plot']);
subplot(1,3,1);
imshow(short, 'InitialMagnification','fit'), title('short');

subplot(1,3,2);
imshow(long, 'InitialMagnification','fit'), title('long');


%% Create the Lum(Y) channels LUTs
% Pre-process
% Luminance short LUT
ShortLut.x = [0    16    45    96   255];
ShortLut.y = [0    20    38    58   115];

% Luminance long LUT
LongLut.x = [ 0 255];
LongLut.y = [ 0  140];

% Take the same points to plot the joined Lum LUT
plot_x = 0:1:255;
plot_y_short = interp1(ShortLut.x,ShortLut.y,plot_x); %LUT short
plot_y_long = interp1(LongLut.x,LongLut.y,plot_x); %LUT long

%subplot(4,1,3);
%plot(plot_x, plot_y_short, plot_x, plot_y_long, plot_x, (plot_y_long+plot_y_short)), grid on;


%% Create the HDR Lum channel 
% The HDR algorithm
% read the Y channels 

YIQ_short = rgb2ntsc(short);
YIQ_long = rgb2ntsc(long);

%% Stream image through HDR algorithm

for x=1:width
    for y=1:height
        YShort1 = round(YIQ_short(y,x,1)*255); %input short
        YLong1 = round(YIQ_long(y,x,1)*255); %input long

        YShort2 = YIQ_short(y,x,2); %input short
        YLong2 = YIQ_long(y,x,2); %input long

        YShort3 = YIQ_short(y,x,3); %input short
        YLong3 = YIQ_long(y,x,3); %input long

        valid_in = 1;
        
        [valid_out, x_out, y_out, HDR1, HDR2, HDR3] = mlhdlc_hdr(YShort1, YShort2, YShort3, YLong1, YLong2, YLong3, plot_y_short, plot_y_long, valid_in, x, y);

        % use x and y to reconstruct image
        if valid_out == 1
            HDR(y_out,x_out,1) = HDR1;
            HDR(y_out,x_out,2) = HDR2;
            HDR(y_out,x_out,3) = HDR3;
        end   
    end
end

%% plot HDR
HDR_rgb = ntsc2rgb(HDR);
subplot(1,3,3);
imshow(HDR_rgb, 'InitialMagnification','fit'), title('hdr ');