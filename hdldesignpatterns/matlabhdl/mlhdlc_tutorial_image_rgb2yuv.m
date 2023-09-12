%% HDL Code Generation for Image Format Conversion from RGB to YUV
% This example shows how to generate HDL code from a MATLAB(R) design that
% converts the image format from RGB to YUV.

%   Copyright 2011-2023 The MathWorks, Inc.

%% MATLAB Design and Test Bench
design_name = 'mlhdlc_rgb2yuv';
testbench_name = 'mlhdlc_rgb2yuv_tb';
%%
% Review the MATLAB design:
open(design_name)
%%
% <include>mlhdlc_rgb2yuv.m</include>

%%
% Review the MATLAB test bench:
open(testbench_name);
%%
% <include>mlhdlc_rgb2yuv_tb.m</include>

%%  Test the MATLAB Algorithm
% To avoid run-time errors, simulate the design with the test bench.
mlhdlc_rgb2yuv_tb

%% Create a Folder and Copy Relevant Files
% Before you generate HDL code for the MATLAB design, copy the
% design and test bench files to a writeable folder. These commands
% copy the files to a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_rgb2yuv']; 
%%
% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);
%%
% Copy files to the temporary directory.
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Create an HDL Coder(TM) Project
% To generate HDL code from a MATLAB design:
%
% 1. Create a HDL Coder project:
%
%   coder -hdlcoder -new mlhdlc_rgb_prj
%
% 2. Add the file |mlhdlc_rgb2yuv.m| to the project as the *MATLAB
% Function* and |mlhdlc_rgb2yuv_tb.m| as the *MATLAB Test Bench*.
%
% 3. Click *Autodefine types* to use the recommended types for the inputs
% and outputs of the MATLAB function |mlhdlc_rgb2yuv|.
%
% <<mlhdlc_rgb2yuv_project.png>>
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.  

%% Run Fixed-Point Conversion and HDL Code Generation
%
% # Click the *Workflow Advisor* button to start the Workflow Advisor.
% # Right click the *HDL Code Generation* task and select *Run to selected task*. 
%
% A HDL file |mlhdlc_rgb2yuv_fixpt.vhd| is generated for the MATLAB design. 
% To examine the generated HDL code for the filter design, click the hyperlink
% to the HDL file in the Code Generation Log window.

%% Clean Up Generated Files
% To clean up the temporary project folder, run these commands:
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_rgb2yuv']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
