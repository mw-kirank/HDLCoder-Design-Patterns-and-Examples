function mlhdlc_vht_enhancededge_tb
% mlhdlc_vht_enhancededge_tb  Compare the image output from 
%       full-frame video reference design and pixel-stream design, and 
%       provide test bench for HDL code generation 

%   Copyright 2015 The MathWorks, Inc.

%#codegen
coder.extrinsic('tic');
coder.extrinsic('toc');
coder.extrinsic('imnoise');
coder.extrinsic('fprintf');
coder.extrinsic('mlhdlc_vht_enhancededge_viewer');

% frm2pix converts an input frame to a stream of pixels and control structures
frm2pix = visionhdl.FrameToPixels(...
        'NumComponents',3,...
        'VideoFormat','240p'); 
[actPixPerLine,actLine,numPixPerFrm] = getparamfromfrm2pix(frm2pix);       

% pix2frm converts a pixel stream and control structures to a full frame
pix2frm = visionhdl.PixelsToFrame(...
        'VideoFormat','240p');

frmFull = imread('peppers.png');
% videoIn reads a rhinos video
% videoIn = vision.VideoFileReader(...
%         'Filename','rhinos.avi',...
%         'VideoOutputDataType','uint8');     
       
pixOutVec = false(numPixPerFrm,1); 
ctrlOutVec = repmat(pixelcontrolstruct,numPixPerFrm,1);

frmIn = zeros(actLine,actPixPerLine,3,'uint8'); %#ok<PREALL>

numFrm = 100;
tic;
for f = 1:numFrm           
    %frmFull = step(videoIn); % use this to get a new frame from VideoReader
    frmIn = imnoise(frmFull,'salt & pepper'); % Add noise        
    
    % Call the pixel-stream design
    [pixInVec,ctrlInVec] = step(frm2pix,frmIn);       
    for p = 1:numPixPerFrm           
        [pixOutVec(p),ctrlOutVec(p)] = mlhdlc_vht_enhancededge(pixInVec(p,:),ctrlInVec(p));                                                          
    end        
    frmOut = step(pix2frm,pixOutVec,ctrlOutVec);    
       
    % Call the full-frame reference design
    [frmGray,frmDenoise,frmEdge,frmRef] = mlhdlc_vht_enhancededge_ref(frmIn);
            
    % Compare the results
    if nnz(imabsdiff(frmRef,frmOut))>20
        fprintf('frame %d: reference and design output differ in more than 20 pixels.\n',f);
        return;
    end 
    
    % Display the results
    mlhdlc_vht_enhancededge_viewer(actPixPerLine,actLine,[frmGray frmDenoise uint8(255*[frmEdge frmOut])],[frmFull frmIn]);
end
t = toc;

fprintf('\n%d frames have been processed in %.2f seconds.\n',numFrm,t);
fprintf('Average frame rate is %.2f frames/second.\n',numFrm/t);
