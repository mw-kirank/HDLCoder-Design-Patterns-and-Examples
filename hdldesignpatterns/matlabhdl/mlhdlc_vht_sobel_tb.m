function mlhdlc_vht_sobel_tb
% mlhdlc_vht_sobel_tb  Provide test bench for HDL code generation

%   Copyright 2015 The MathWorks, Inc.

%#codegen
coder.extrinsic('tic');
coder.extrinsic('toc');   
coder.extrinsic('fprintf');
coder.extrinsic('mlhdlc_vht_sobel_viewer');

% frm2pix converts an input frame to a stream of pixels and control structures
frm2pix = visionhdl.FrameToPixels(...
        'VideoFormat','1080p'); 
[actPixPerLine,actLine,numPixPerFrm] = getparamfromfrm2pix(frm2pix);

% pix2frm converts a pixel stream and control structures to a full frame
pix2frm = visionhdl.PixelsToFrame(...
        'VideoFormat','1080p');            
 
% videoIn reads a rhinos video

frmFull = imread('cameraman.tif'); 
% videoIn = vision.VideoFileReader(... 
%         'Filename','rhinos.avi',...
%         'ImageColorSpace','Intensity',...
%         'VideoOutputDataType','uint8');         
         
pixOutVec = false(numPixPerFrm,1);
ctrlOutVec = repmat(pixelcontrolstruct,numPixPerFrm,1);

numFrm = 10;
tic;
for f = 1:numFrm       
    %frmFull = step(videoIn); % use this to get a new frame from VideoReader
    frmIn = imresize(frmFull,[actLine actPixPerLine]); % Enlarge the frame
    [pixInVec,ctrlInVec] = step(frm2pix,frmIn);          
    for p = 1:numPixPerFrm            
        [pixOutVec(p),ctrlOutVec(p)] = mlhdlc_vht_sobel(pixInVec(p),ctrlInVec(p));                                           
    end             
    frmOut = step(pix2frm,pixOutVec,ctrlOutVec);    
    
    mlhdlc_vht_sobel_viewer(actPixPerLine,actLine,[frmIn uint8(255*frmOut)]);            
end
t = toc;

fprintf('\n%d frames have been processed in %.2f seconds.\n',numFrm,t);
fprintf('Average frame rate is %.2f frames/second.\n',numFrm/t);
