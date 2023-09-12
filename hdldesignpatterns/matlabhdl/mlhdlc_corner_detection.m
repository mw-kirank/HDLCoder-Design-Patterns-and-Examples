%#codegen
function [valid, ed, xfo, yfo, cm] = mlhdlc_corner_detection(data_in)
%   Copyright 2011-2019 The MathWorks, Inc.

[~, ed, xfo, yfo] = mlhdlc_sobel(data_in);

cm = compute_corner_metric(xfo, yfo);

% compute valid signal
persistent cnt
if isempty(cnt)
  cnt = 0;
end
cnt = cnt + 1;
valid = cnt > 3*80+3 && cnt <= 80*80+3*80+3;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bm = compute_corner_metric(gh, gv)

cmh = make_buffer_matrix_gh(gh);
cmv = make_buffer_matrix_gv(gv);
bm = compute_harris_metric(cmh, cmv);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bm = make_buffer_matrix_gh(gh)

persistent b1 b2 b3 b4;
if isempty(b1)
    b1 = dsp.Delay('Length', 80);
    b2 = dsp.Delay('Length', 80);
    b3 = dsp.Delay('Length', 80);
    b4 = dsp.Delay('Length', 80);
end

b1p = step(b1, gh);
b2p = step(b2, b1p);
b3p = step(b3, b2p);
b4p = step(b4, b3p);

cc = [b4p b3p b2p b1p gh];

persistent h1 h2 h3 h4;
if isempty(h1)
    h1 = dsp.Delay();
    h2 = dsp.Delay();
    h3 = dsp.Delay();
    h4 = dsp.Delay();
end

h1p = step(h1, cc);
h2p = step(h2, h1p);
h3p = step(h3, h2p);
h4p = step(h4, h3p);

bm = [h4p h3p h2p h1p cc];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bm = make_buffer_matrix_gv(gv)

persistent b1 b2 b3 b4;
if isempty(b1)
    b1 = dsp.Delay('Length', 80);
    b2 = dsp.Delay('Length', 80);
    b3 = dsp.Delay('Length', 80);
    b4 = dsp.Delay('Length', 80);
end

b1p = step(b1, gv);
b2p = step(b2, b1p);
b3p = step(b3, b2p);
b4p = step(b4, b3p);

cc = [b4p b3p b2p b1p gv];

persistent h1 h2 h3 h4;
if isempty(h1)
    h1 = dsp.Delay();
    h2 = dsp.Delay();
    h3 = dsp.Delay();
    h4 = dsp.Delay();
end

h1p = step(h1, cc);
h2p = step(h2, h1p);
h3p = step(h3, h2p);
h4p = step(h4, h3p);

bm = [h4p h3p h2p h1p cc];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cm = compute_harris_metric(gh, gv)

[g1, g2, g3] = gaussian_filter(gh, gv);
[s1, s2, s3] = reduce_matrix(g1, g2, g3);

cm = (((s1*s3) - (s2*s2)) - (((s1+s3) * (s1+s3)) * 0.04));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [g1, g2, g3] = gaussian_filter(gh, gv)

%g=fspecial('gaussian',[5 5],1.5);
g = [0.0144    0.0281    0.0351    0.0281    0.0144
     0.0281    0.0547    0.0683    0.0547    0.0281
     0.0351    0.0683    0.0853    0.0683    0.0351
     0.0281    0.0547    0.0683    0.0547    0.0281
     0.0144    0.0281    0.0351    0.0281    0.0144];

g1 = (gh .* gh) .* g(:)';
g2 = (gh .* gv) .* g(:)';
g3 = (gv .* gv) .* g(:)';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s1, s2, s3] = reduce_matrix(g1, g2, g3)

s1 = sum(g1);
s2 = sum(g2);
s3 = sum(g3);

end

