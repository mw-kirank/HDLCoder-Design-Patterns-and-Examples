function [x_out, y_out, y_data_out, u_data_out, v_data_out] = ...
                        mlhdlc_rgb2yuv(x_in, y_in, r_in, g_in, b_in)
%#codegen

%   Copyright 2011-2019 The MathWorks, Inc.

persistent RGB_Reg YUV_Reg
persistent x1 x2 y1 y2

if isempty(RGB_Reg)
    RGB_Reg = zeros(3,1);
    YUV_Reg = zeros(3,1);
    x1 = 0; x2 = 0; y1 = 0; y2 = 0;
end

D = [.299  .587  .144; -.147 -.289  .436; .615 -.515 -.1];
C = [0; 128; 128];

RGB = [r_in; g_in; b_in];

YUV_1 = D*RGB_Reg;
YUV_2 = YUV_1 + C;
RGB_Reg = RGB;

y_data_out = round(YUV_Reg(1));
u_data_out = round(YUV_Reg(2));
v_data_out = round(YUV_Reg(3));
YUV_Reg = YUV_2;

x_out = x2; x2 = x1; x1 = x_in;
y_out = y2; y2 = y1; y1 = y_in;

