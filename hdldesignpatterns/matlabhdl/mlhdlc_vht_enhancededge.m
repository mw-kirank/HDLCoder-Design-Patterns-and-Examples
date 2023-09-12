function [pixOut,ctrlOut] = mlhdlc_vht_enhancededge(pixIn,ctrlIn)
% mlhdlc_vht_enhancededge  Implement algorithms using pixel-stream 
%       System objects from the Vision HDL Toolbox

%   Copyright 2015 The MathWorks, Inc.

%#codegen
persistent rgb2gray medfil sobel mclose;
if isempty(rgb2gray)
    rgb2gray = visionhdl.ColorSpaceConverter(...
            'Conversion','RGB to intensity');    
    medfil = visionhdl.MedianFilter;        
    sobel = visionhdl.EdgeDetector(...
            'Threshold',7,...
            'OverflowAction','Saturate');    
    mclose = visionhdl.Closing(...
            'Neighborhood',[0 1 0;1 1 1;0 1 0]);    
end

[pixGray,ctrlGray] = step(rgb2gray,pixIn,ctrlIn);         % Convert RGB to grayscale
[pixDenoise,ctrlDenoise] = step(medfil,pixGray,ctrlGray); % Remove noise
[pixEdge,ctrlEdge] = step(sobel,pixDenoise,ctrlDenoise);  % Detect edges
[pixClose,ctrlClose] = step(mclose,pixEdge,ctrlEdge);     % Apply closing

ctrlOut = ctrlClose;
pixOut = pixClose;
