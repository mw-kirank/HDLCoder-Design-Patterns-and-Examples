function [valid_out, x_out, y_out, ...
    HDR1, HDR2, HDR3] = mlhdlc_hdr(YShort1, YShort2, YShort3, ...
    YLong1, YLong2, YLong3, ...
    plot_y_short_in, plot_y_long_in, ... 
    valid_in, x, y)
%

%   Copyright 2013-2015 The MathWorks, Inc.

% This design implements a high dynamic range imaging algorithm.

plot_y_short = plot_y_short_in;
plot_y_long = plot_y_long_in;

%% Apply Lum(Y) channels LUTs
y_short = plot_y_short(uint8(YShort1)+1);
y_long = plot_y_long(uint8(YLong1)+1);

y_HDR = (y_short+y_long);

%% Create HDR Chorm channels
% HDR per color

HDR1 = y_HDR * 2^-8;
HDR2 = (YShort2+YLong2) * 2^-1;
HDR3 = (YShort3+YLong3) * 2^-1;

%% Pass on valid signal and pixel location

valid_out = valid_in;
x_out = x;
y_out = y;

end