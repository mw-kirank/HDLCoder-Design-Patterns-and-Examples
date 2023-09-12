%% Enhanced Edge Detection from Noisy Color Video
% This example demonstrates how to develop a complex pixel-stream video 
% processing algorithm, accelerate its simulation using MATLAB Coder(TM),
% and generate HDL code from the design. The algorithm enhances the edge 
% detection from noisy color video. You must have a MATLAB Coder license to 
% run this example. 

%% Test Bench
% In the 
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
% the *videoIn* object reads each frame from a color video source, and the 
% |imnoise| function adds salt and pepper noise. This noisy color image is 
% passed to the *frm2pix* object, which converts the full image frame to a 
% stream of pixels and control structures. The function 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge.m')) mlhdlc_vht_enhancededge>
% is then called to process one pixel (and its associated control 
% structure) at a time. After we process the entire pixel-stream and 
% collect the output stream, the *pix2frm* object converts the output 
% stream to full-frame video. A full-frame reference design 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge_ref.m')) mlhdlc_vht_enhancededge_ref>
% is also
% called to process the noisy color image. Its output is compared with
% that of the pixel-stream design. 
% The function <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge_viewer.m')) mlhdlc_vht_enhancededge_viewer>
% is called to display video outputs.
%
% The workflow above is implemented in the following lines of
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge_tb.m')) mlhdlc_vht_enhancededge_tb>.
%
%        ...
%        frmIn = zeros(actLine,actPixPerLine,3,'uint8');       
%        for f = 1:numFrm           
%            frmFull = step(videoIn);                  % Get a new frame    
%            frmIn = imnoise(frmFull,'salt & pepper'); % Add noise        
%    
%            % Call the pixel-stream design
%            [pixInVec,ctrlInVec] = step(frm2pix,frmIn);       
%            for p = 1:numPixPerFrm    
%                [pixOutVec(p),ctrlOutVec(p)] = mlhdlc_vht_enhancededge(pixInVec(p,:),ctrlInVec(p));                                  
%            end        
%            frmOut = step(pix2frm,pixOutVec,ctrlOutVec);    
%       
%            % Call the full-frame reference design
%            [frmGray,frmDenoise,frmEdge,frmRef] = mlhdlc_vht_enhancededge_ref(frmIn);
%            
%            % Compare the results
%            if nnz(imabsdiff(frmRef,frmOut))>20
%                fprintf('frame %d: reference and design output differ in more than 20 pixels.\n',f);
%                return;
%            end 
%    
%            % Display the results
%            mlhdlc_vht_enhancededge_viewer(actPixPerLine,actLine,[frmGray frmDenoise uint8(255*[frmEdge frmOut])],[frmFull frmIn]);
%        end
%        ...
% 
% Since frmGray and frmDenoise are uint8 data type while frmEdge and frmOut
% are logical, *uint8(255x[frmEdge frmOut])* maps logical false and true 
% to uint8(0) and uint8(255), respectively, so that matrices can be
% concatenated. 
%
% Both *frm2pix* and *pix2frm* are used to convert between full-frame and
% pixel-stream domains. The inner for-loop performs pixel-stream 
% processing. The rest of the test bench performs full-frame processing.
%
% Before the test bench terminates, frame rate is displayed to illustrate 
% the simulation speed.
%
% For the functions that do not support C code generation, such as |tic|, 
% |toc|, |imnoise|, and |fprintf| in this example, use *coder.extrinsic* to 
% declare them as extrinsic functions. Extrinsic functions are excluded 
% from MEX generation. The simulation executes them in the regular 
% interpreted mode. Since |imnoise| is not included in the C code generation 
% process, the compiler cannot infer the data type and size of frmIn.
% To fill in this missing piece, we add the statement 
% *frmIn = zeros(actLine,actPixPerLine,3,'uint8')* before the outer for-loop.


%% Pixel-Stream Design
% The function 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge.m')) mlhdlc_vht_enhancededge>
% accepts a pixel stream and a structure consisting of five control signals, and returns a modified 
% pixel stream and control structure. For more information on the streaming 
% pixel protocol used by System objects from the Vision HDL Toolbox, see 
% the 
% <matlab:helpview(fullfile(docroot,'visionhdl','ug','streaming-pixel-interface.html')) documentation>.
%
% In this example, the *rgb2gray* object converts a color image to grayscale, 
% *medfil* removes the salt and pepper noise. 
% *sobel* highlights the edge. Finally,
% the *mclose* object performs morphological closing to enhance the edge 
% output. The code is shown below.
%
%        [pixGray,ctrlGray] = step(rgb2gray,pixIn,ctrlIn);         % Convert RGB to grayscale
%        [pixDenoise,ctrlDenoise] = step(medfil,pixGray,ctrlGray); % Remove noise
%        [pixEdge,ctrlEdge] = step(sobel,pixDenoise,ctrlDenoise);  % Detect edges
%        [pixClose,ctrlClose] = step(mclose,pixEdge,ctrlEdge);     % Apply closing

%% Full-Frame Reference Design
% When designing a complex pixel-stream video processing algorithm, it is a 
% good practice to develop a parallel reference design using functions from 
% the Image Processing Toolbox(TM). These functions process full image 
% frames. Such a reference design helps verify the implementation of 
% the pixel-stream design by comparing the output image from the full-frame 
% reference design to the output of the pixel-stream design.
%
% The function 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge_ref.m')) mlhdlc_vht_enhancededge_ref>
% contains a similar set of four functions as in the
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_enhancededge.m')) mlhdlc_vht_enhancededge>.
% The key difference is that the functions from Image Processing Toolbox 
% process full-frame data.
%
% Due to the implementation difference between |edge| function and
% visionhdl.EdgeDetector System object, reference and design output are 
% considered matching if frmOut and frmRef differ in no greater than 20 pixels.

%% Create MEX File and Simulate the Design
% So as not to pollute your current working folder, execute the following 
% lines of code to copy the necessary example files into a temporary folder.
currDir = pwd;
tempDir = tempname;

% Create a temporary folder and copy the MATLAB files.
mkdir(tempDir);
demoDir = fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl');   
copyfile(fullfile(demoDir,'mlhdlc_vht_enhancededge_tb.m'),tempDir);
copyfile(fullfile(demoDir,'mlhdlc_vht_enhancededge.m'),tempDir);
copyfile(fullfile(demoDir,'mlhdlc_vht_enhancededge_ref.m'),tempDir);
copyfile(fullfile(demoDir,'mlhdlc_vht_enhancededge_viewer.m'),tempDir);
cd(tempDir);

%%
% Generate and execute the MEX file.
fprintf('Generating the MEX file, please wait ..\n');
codegen('mlhdlc_vht_enhancededge_tb');
fprintf('Executing the MEX file ..\n');
mlhdlc_vht_enhancededge_tb_mex;

%% 
%
% <<mlhdlc_vht_enhancededge_viewers.png>>
%
% The upper video player displays the original color video on the left, 
% and its noisy version after adding salt and pepper noise on the right. 
% The lower video player, from left to right, represents: the
% grayscale image after color space conversion, the de-noised version after
% median filter, the edge output after edge detection, and the enhanced 
% edge output after morphological closing operation.
%
% Note that in the lower video chain, only the enhanced edge output 
% (right-most video) is generated from pixel-stream design. The other three 
% are the intermediate videos from the full-frame reference design. 
% To display all of the four videos from the pixel-stream 
% design, you would have written the design file to output four sets of 
% pixels and control signals, and instantiated three more 
% *visionhdl.PixelsToFrame* objects to convert the three intermediate pixel 
% streams back to frames. For the sake of simulation speed and the clarity
% of the code, this example does not implement the intermediate
% pixel-stream displays.


%% HDL Code Generation
% To create a new project, enter the following command in the temporary 
% folder
%
%   coder -hdlcoder -new EnhancedEdgeDetectionProject
%
% Then, add the file 'EnhancedEdgeDetectionHDLDesign.m' to the project as the MATLAB
% Function and 'EnhancedEdgeDetectionHDLTestBench.m' as the MATLAB Test Bench.
%
% Refer to
% <matlab:helpview(fullfile(docroot,'hdlcoder','examples','getting-started-with-matlab-to-hdl-workflow.html')) Getting Started with MATLAB to HDL Workflow>
% for a tutorial on creating and populating MATLAB HDL Coder projects. 
%
% Launch the Workflow Advisor. In the Workflow Advisor, right-click the 
% 'Code Generation' step. Choose the option 'Run to selected task' to 
% run all the steps from the beginning through HDL code generation. 
%
% Examine the generated HDL code by clicking the links in the log window.
%
% Run the following commands to clean up the temporary project folder.
clear mlhdlc_vht_enhancededge_tb_mex;
cd(currDir);
rmdir(tempDir,'s');
clear currDir tempDir demoDir;

%%
%   Copyright 2014-2023 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
