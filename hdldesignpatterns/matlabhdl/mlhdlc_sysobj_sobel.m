function [xfd, yfd, e] = mlhdlc_sysobj_sobel(u)
% Pipelined Sobel Edge Detection algorithm on serialized image.

%   Copyright 2011-2015 The MathWorks, Inc.

numCols=100;
thresh=uint8(157);

[xfo, yfo] =  s_filter(u, numCols);

persistent h1 h2 h3;
if isempty(h1)
    h1 = dsp.Delay;
    h2 = dsp.Delay;
    h3 = dsp.Delay;
end

xfd = step(h1, xfo);
yfd = step(h2, yfo);
ax = abs(xfd);
ay = abs(yfd);
t = (ax + ay >= thresh);
e = step(h3, t);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute convolution of serialized image data with sobel masks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xfo, yfo] =  s_filter(u, numCols)


persistent buf1 buf2;
if isempty(buf1)
    buf1 = dsp.Delay('Length', numCols);
    buf2 = dsp.Delay('Length', numCols);
end

lb1 = step(buf1, u);
lb2 = step(buf2, lb1);


persistent h1 h2 h3 h4 h5 h6;
if isempty(h1)
    h1 = dsp.Delay;
    h2 = dsp.Delay;
    h3 = dsp.Delay;
    h4 = dsp.Delay;
    h5 = dsp.Delay;
    h6 = dsp.Delay;
end

ud1 = step(h1, u);
ud2 = step(h2, ud1);

lb1d1 = step(h3, lb1);
lb1d2 = step(h4, lb1d1);

lb2d1 = step(h5, lb2);
lb2d2 = step(h6, lb2d1);

xfo = xf(u, ud1, ud2, lb2, lb2d1, lb2d2);
yfo = yf(ud2, u, lb1d2, lb1, lb2d2, lb2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute x gradient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xf_out = xf(u, xd1, xd2, lb2, zd1, zd2)
c2 = 2;

persistent h1 h2;
if isempty(h1)
    h1 = dsp.Delay;
    h2 = dsp.Delay;
end

t1 = xd1 * c2;
a1 = u + t1 + xd2;
pa1 = step(h1, a1);

t1 = zd1 * c2;
a2 = lb2 + t1 + zd2;
pa2 = step(h2, a2);

xf_out = pa1 - pa2;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute y gradient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yf_out = yf(xd2, u, yd2, lb1, zd2, lb2)

persistent h1 h2 h3;
if isempty(h1)
    h1 = dsp.Delay;
    h2 = dsp.Delay;    
    h3 = dsp.Delay;
end

t = xd2 - u;

pa1 = step(h1, t);

t = yd2 - lb1;
c2 = 2;
a2 = c2 * t;
pa2 = step(h2, a2);

t = zd2 - lb2;
pa3 = step(h3, t);

yf_out = pa1 + pa2 + pa3;

end
