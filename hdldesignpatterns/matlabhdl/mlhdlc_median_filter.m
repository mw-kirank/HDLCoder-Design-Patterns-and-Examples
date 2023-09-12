%#codegen
function [pixel_val, pixel_valid] = mlhdlc_median_filter(c_data, c_idx)
%   Copyright 2011-2019 The MathWorks, Inc.

smax = 9;
persistent window;
if isempty(window)
    window = zeros(smax, smax);
end

cp = ceil(smax/2); % center pixel;

w3 = -1:1;
w5 = -2:2;
w7 = -3:3;
w9 = -4:4;

r3 = cp + w3;      % 3x3 window
r5 = cp + w5;      % 5x5 window
r7 = cp + w7;      % 7x7 window
r9 = cp + w9;      % 9x9 window

d3x3 = window(r3, r3);
d5x5 = window(r5, r5);
d7x7 = window(r7, r7);
d9x9 = window(r9, r9);

center_pixel = window(cp, cp);


% use 1D filter for 3x3 region
outbuf = get_median_1d(d3x3(:)');
[min3, med3, max3] = getMinMaxMed_1d(outbuf);

% use 2D filter for 5x5 region
outbuf = get_median_2d(d5x5);
[min5, med5, max5] = getMinMaxMed_2d(outbuf);

% use 2D filter for 7x7 region
outbuf = get_median_2d(d7x7);
[min7, med7, max7] = getMinMaxMed_2d(outbuf);

% use 2D filter for 9x9 region
outbuf = get_median_2d(d9x9);
[min9, med9, max9] = getMinMaxMed_2d(outbuf);


pixel_val = get_new_pixel(min3, med3, max3, ...
    min5, med5, max5, ...
    min7, med7, max7, ...
    min9, med9, max9, ...
    center_pixel);


% we need to wait until 9 cycles for the buffer to fill up
% output is not valid every time we start from col1 for 9 cycles.
persistent datavalid
if isempty(datavalid)
    datavalid = false;
end
pixel_valid = datavalid;
datavalid = (c_idx >= smax);


% build the 9x9 buffer
window(:,2:smax) = window(:,1:smax-1);
window(:,1) = c_data;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [min, med, max] = getMinMaxMed_1d(inbuf)

max = inbuf(1);
med = inbuf(ceil(numel(inbuf)/2));
min = inbuf(numel(inbuf));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [min, med, max] = getMinMaxMed_2d(inbuf)

[nrows, ncols] = size(inbuf);
max = inbuf(1, 1);
med = inbuf(ceil(nrows/2), ceil(ncols/2));
min = inbuf(nrows, ncols);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_pixel  = get_new_pixel(...
    min3, med3, max3, ...
    min5, med5, max5, ...
    min7, med7, max7, ...
    min9, med9, max9, ...
    center_data)

if (med3 > min3 && med3 < max3)
    new_pixel = get_center_data(min3, med3, max3,center_data);
elseif (med5 > min5 && med5 < max5)
    new_pixel = get_center_data(min5, med5, max5,center_data);
elseif (med7 > min7 && med7 < max7)
    new_pixel = get_center_data(min7, med7, max7,center_data);
elseif (med9 > min9 && med9 < max9)
    new_pixel = get_center_data(min9, med9, max9,center_data);
else
    new_pixel = center_data;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [new_data] = get_center_data(min,med,max,center_data)
if center_data <= min || center_data >= max
    new_data = med;
else
    new_data = center_data;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform median 1d computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outbuf = get_median_1d(inbuf)

numpixels = length(inbuf);

tbuf = inbuf;

for ii=coder.unroll(1:numpixels)
    if bitand(ii,uint32(1)) == 1  
        tbuf = compare_stage1(tbuf);
    else
        tbuf = compare_stage2(tbuf);
    end
end

outbuf = tbuf;

end

function outbuf = compare_stage1(inbuf)
numpixels = length(inbuf);
tbuf = compare_stage(inbuf(1:numpixels-1));
outbuf = [tbuf(:)' inbuf(numpixels)];
end

function outbuf = compare_stage2(inbuf)
numpixels = length(inbuf);
tbuf = compare_stage(inbuf(2:numpixels));
outbuf = [inbuf(1) tbuf(:)'];
end

function [outbuf] = compare_stage(inbuf)

step = 2;
numpixels = length(inbuf);

outbuf = inbuf;

for ii=coder.unroll(1:step:numpixels)
    t = compare_pixels([inbuf(ii), inbuf(ii+1)]);
    outbuf(ii) = t(1);
    outbuf(ii+1) = t(2);
end

end

function outbuf = compare_pixels(inbuf)
if (inbuf(1) > inbuf(2))
    outbuf = [inbuf(1), inbuf(2)];
else
    outbuf = [inbuf(2), inbuf(1)];
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform median 2d computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outbuf = get_median_2d(inbuf)

outbuf = inbuf;
[nrows, ncols] = size(inbuf);
for ii=coder.unroll(1:ncols)
    colData = outbuf(:, ii)';
    colDataOut = get_median_1d(colData)';
    outbuf(:, ii) = colDataOut;
end
for ii=coder.unroll(1:nrows)
    rowData = outbuf(ii, :);
    rowDataOut = get_median_1d(rowData);
    outbuf(ii, :) = rowDataOut;
end

end