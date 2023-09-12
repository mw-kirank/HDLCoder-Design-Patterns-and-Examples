function [pixOut,ctrlOut] = mlhdlc_vht_sobel(pixIn,ctrlIn)
% mlhdlc_vht_sobel  Implement video processing algorithms using
%     pixel-stream System objects from the Vision HDL Toolbox

%   Copyright 2015 The MathWorks, Inc.

%#codegen
persistent sobel;
if isempty(sobel)
    sobel = visionhdl.EdgeDetector(...
            'Threshold',2);
end

[pixOut,ctrlOut] = step(sobel,pixIn,ctrlIn);