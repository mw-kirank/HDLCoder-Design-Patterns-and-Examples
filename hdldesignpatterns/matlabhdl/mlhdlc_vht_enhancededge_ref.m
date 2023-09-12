function [frmGray,frmDenoise,frmEdge,frmClose] =...
    mlhdlc_vht_enhancededge_ref(frmIn)       
% mlhdlc_vht_enhancededge_ref  Implement algorithm using functions from 
%       Image Processing Toolbox
%    mlhdlc_vht_enhancededge_ref accepts a noisy RGB input frame frmIn, 
%    and returns intermediate frames (frmGray, frmDenoise, and frmEdge) and 
%    final result frmClose after morphological closing.

%   Copyright 2015 The MathWorks, Inc.

%#codegen

frmGray = rgb2gray(frmIn);  % Convert RGB to grayscale
frmDenoise = medfilt2(frmGray,'symmetric');  % Remove noise
frmEdge = edge(frmDenoise,'sobel',7/255,'nothinning');  % Detect edges
frmClose = imclose(frmEdge,strel('disk',1));  % Apply closing