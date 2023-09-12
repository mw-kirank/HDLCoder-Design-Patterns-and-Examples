%% Contrast Adjustment
% This example shows how to generate HDL code from a MATLAB(R) design
% that adjusts image contrast by linearly scaling pixel values.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Algorithm
%
% Contrast adjustment adjusts the contrast of an image by linearly scaling
% the pixel values between upper and lower limits. Pixel values that are
% above or below this range are saturated to the upper or lower limit
% value, respectively.
%
% <<mlhdlc_contrast_adjust.png>>

%% MATLAB Design
design_name = 'mlhdlc_image_scale';
testbench_name = 'mlhdlc_image_scale_tb';

%%
% Let us take a look at the MATLAB design
type(design_name);

%%
type(testbench_name);

%% Simulate the Design
% It is a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_image_scale_tb

%% Setup for the Example
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_scale']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

% copy files to the temp dir
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_img_peppers.png'), mlhdlc_temp_dir);


%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_scale_prj
%
% Next, add the file 'mlhdlc_image_scale.m' to the project as the MATLAB
% Function and 'mlhdlc_image_scale_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch the Workflow Advisor from the Build tab and right click on the 
% 'Code Generation' step and choose the option 'Run to selected task' to 
% run all the steps from the beginning through the HDL code generation. 
%
% Examine the generated HDL code by clicking on the hyperlinks in the 
% Code Generation Log window.

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_scale']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');


displayEndOfDemoMessage(mfilename)
