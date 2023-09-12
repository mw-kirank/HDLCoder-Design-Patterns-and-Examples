%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% heq.m
% Histogram Equalization Algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x_out, y_out, pixel_out] = ...
    mlhdlc_heq(x_in, y_in, pixel_in, width, height)

%   Copyright 2011-2015 The MathWorks, Inc.

persistent histogram
persistent transferFunc
persistent histInd
persistent cumSum

if isempty(histogram)
    histogram = zeros(1, 2^14);
    transferFunc = zeros(1, 2^14);
    histInd = 0;
    cumSum = 0;
end

% Figure out indexes based on where we are in the frame
if y_in < height && x_in < width % valid pixel data
    histInd = pixel_in + 1;
elseif y_in == height && x_in == 0 % first column of height+1
    histInd = 1;
elseif y_in >= height % vertical blanking period
    histInd = min(histInd + 1, 2^14);
elseif y_in < height % horizontal blanking - do nothing
    histInd = 1;
end

%Read histogram (must be outside conditional logic)
histValRead = histogram(histInd);

%Read transfer function (must be outside conditional logic)
transValRead = transferFunc(histInd);

%If valid part of frame add one to pixel bin and keep transfer func val
if y_in < height && x_in < width
    histValWrite = histValRead + 1; %Add pixel to bin
    transValWrite = transValRead; %Write back same value
    cumSum = 0;
elseif y_in >= height %In blanking time index through all bins and reset to zero
    histValWrite = 0;
    transValWrite = cumSum + histValRead;
    cumSum = transValWrite;
else
    histValWrite = histValRead;
    transValWrite = transValRead;
end

%Write histogram (must be outside conditional logic)
histogram(histInd) = histValWrite;

%Write transfer function (must be outside conditional logic)
transferFunc(histInd) = transValWrite;

pixel_out = transValRead;
x_out = x_in;
y_out = y_in;

