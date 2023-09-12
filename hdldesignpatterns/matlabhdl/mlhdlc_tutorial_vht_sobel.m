%% Accelerate a Pixel-Streaming Design Using MATLAB Coder
% This example demonstrates a workflow for accelerating a pixel-stream video 
% processing algorithm using MATLAB Coder(TM) and generating HDL code from 
% the design. You must have a MATLAB Coder license to run this example.
%
% Acceleration with MATLAB Coder enables you to simulate large frame sizes, 
% such as 1080p video, at practical speeds. Use this acceleration workflow 
% after you have debugged the algorithm using a small frame size. Testing a 
% design with a small image is demonstrated in the 
% <docid:visionhdl_examples#example-ex32981414> example.

%% How MATLAB Coder Works
% MATLAB Coder generates C code from MATLAB(R) code. Code generation 
% accelerates simulation by locking-down the sizes and data types of 
% variables. This process removes the overhead of the interpreted 
% language checking for size and data type in every line of code. This 
% example compiles both the test bench file 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel_tb.m')) mlhdlc_vht_sobel_tb> 
% and the design file
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel.m')) mlhdlc_vht_sobel>
% into a MEX function, 
% and uses the resulting MEX file to speed up the simulation.
%
% The directive (or pragma) *%#codegen* beneath the function signature 
% indicates that you intend to generate code for the MATLAB algorithm. 
% Adding this directive instructs the MATLAB code analyzer to help you 
% diagnose and fix violations that would result in errors during code 
% generation. The directive *%#codegen* does not affect interpreted 
% simulation. 

%% Best Practices
% Debugging simulations with large frame sizes is impractical in 
% interpreted mode due to long simulation time. However, debugging a MEX 
% simulation is challenging due to lack of debug access into the code.
%
% To avoid these scenarios, a best practice is to develop and verify the 
% algorithm and test bench using a thumbnail frame size. In most cases, the 
% HDL-targeted design can be implemented with no dependence on frame size. 
% Once you are confident that the design and test bench are working 
% correctly, then increase the frame size in the test bench, and use MATLAB 
% Coder to accelerate the simulation. To increase the frame size, the test 
% bench only requires minor changes, as you can see by comparing 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel_tb.m')) mlhdlc_vht_sobel_tb> 
% with the 
% <matlab:edit(fullfile(matlabroot,'examples','visionhdl','main','PixelStreamingDesignHDLTestBench.m')) PixelStreamingDesignHDLTestBench> 
% in <docid:visionhdl_examples#example-ex32981414>.

%% Test Bench
% In the test bench 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel_tb.m')) mlhdlc_vht_sobel_tb>, 
% the *videoIn* object reads each frame from a video source, and the *imresize* function 
% interpolates this frame from 240p to 1080p. This 1080p 
% image is passed to the *frm2pix* object, which converts the full image 
% frame to a stream of pixels and control structures. The function 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel.m')) mlhdlc_vht_sobel>
% is then called to process one pixel (and its associated control 
% structure) at a time. After we process the entire pixel-stream and 
% collect the output stream, the *pix2frm* object converts the output 
% stream to full-frame video. The *mlhdlc_vht_sobel_viewer* function 
% displays the output and original images side-by-side. 
%
% The workflow above is implemented in the following lines of
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel_tb.m')) mlhdlc_vht_sobel_tb>.
%
%       ...
%       for f = 1:numFrm       
%           frmFull = step(videoIn);       % Get a new frame
%           frmIn = imresize(frmFull,[actLine actPixPerLine]); % Enlarge the frame
%    
%           [pixInVec,ctrlInVec] = step(frm2pix,frmIn);          
%           for p = 1:numPixPerFrm    
%               [pixOutVec(p),ctrlOutVec(p)] = mlhdlc_vht_sobel(pixInVec(p),ctrlInVec(p));                                           
%           end             
%           frmOut = step(pix2frm,pixOutVec,ctrlOutVec);    
%    
%           mlhdlc_vht_sobel_viewer(actPixPerLine,actLine,[frmIn uint8(255*frmOut)]);          
%       end
%       ...
% 
% The data type of frmIn is uint8 while that of frmOut, the edge detection 
% output, is logical. Matrices of different data types cannot be 
% concatenated, so *uint8(255*frmOut)* maps logical false and true to 
% uint8(0) and uint8(255), respectively.
%
% Both *frm2pix* and *pix2frm* are used to convert between full-frame and
% pixel-stream domains. The inner for-loop performs pixel-stream 
% processing. The rest of the test bench performs full-frame processing 
% (i.e., *videoIn*, *imresize*, and *viewer* inside the 
% *DesignAccelerationHDLViewer* function).
%
% Before the test bench terminates, frame rate is displayed to 
% illustrate the simulation speed.
%
% Not all functions used in the test bench support C code generation. For 
% those that do not, such as |tic|, |toc|, |fprintf|, use *coder.extrinsic* 
% to declare them as extrinsic functions. Extrinsic functions are excluded 
% from MEX generation. The simulation executes them in the regular 
% interpreted mode.

%% Pixel-Stream Design
% The function 
% <matlab:edit(fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl','mlhdlc_vht_sobel.m')) mlhdlc_vht_sobel>
% accepts a pixel stream and five control signals, and returns a modified 
% pixel stream and control signals. For more information on the streaming 
% pixel protocol used by System objects from the Vision HDL Toolbox, see 
% the 
% <matlab:helpview(fullfile(docroot,'visionhdl','ug','streaming-pixel-interface.html')) documentation>.
%
% In this example, the function contains the Edge Detector System object.
%
% The focus of this example is the workflow, not the algorithm design 
% itself. Therefore, the design code is quite simple. Once you are familiar 
% with the workflow, it is straightforward to implement advanced video 
% algorithms by taking advantage of the functionality provided by the 
% System objects from Vision HDL Toolbox.

%% Create MEX File and Simulate the Design
% So as not to pollute your current working folder, execute the following lines 
% of code to copy the necessary example files into a temporary folder.
currDir = pwd;
tempDir = tempname;

% Create a temporary folder and copy the MATLAB files.
mkdir(tempDir);
demoDir = fullfile(matlabroot,'toolbox','hdlcoder','hdldesignpatterns','matlabhdl');  
copyfile(fullfile(demoDir,'mlhdlc_vht_sobel_tb.m'),tempDir);
copyfile(fullfile(demoDir,'mlhdlc_vht_sobel.m'),tempDir);
copyfile(fullfile(demoDir,'mlhdlc_vht_sobel_viewer.m'),tempDir);
cd(tempDir);

%%
% Generate and execute the MEX file.
fprintf('Generating the MEX file, please wait ..\n');
codegen('mlhdlc_vht_sobel_tb');
fprintf('Executing the MEX file ..\n');
mlhdlc_vht_sobel_tb_mex;

%% 
%
% <<mlhdlc_vht_sobel_viewers.png>>
%
% The *viewer* displays the original video on the left, and the output on 
% the right.

%% HDL Code Generation
% Enter the following command to create a new HDL Coder(TM) project in the 
% temporary folder
%
%   coder -hdlcoder -new DesignAccelerationProject
%
% Then, add the file 'DesignAccelerationHDLDesign.m' to the project as the MATLAB
% Function and 'DesignAccelerationHDLTestBench.m' as the MATLAB Test Bench.
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
clear mlhdlc_vht_sobel_tb_mex;
cd(currDir);
rmdir(tempDir,'s');
clear currDir tempDir demoDir;

%%
%   Copyright 2015-2023 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
