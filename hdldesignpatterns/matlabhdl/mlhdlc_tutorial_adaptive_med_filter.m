%% HDL Code Generation for Adaptive Median Filter
% This example shows how to generate HDL code from a MATLAB(R) design that 
% implements an adaptive median filter algorithm and generates HDL code.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Adaptive Filter MATLAB Design
% An adaptive median filter performs spatial processing to reduce noise in
% an image. The filter compares each pixel in the image to the surrounding
% pixels. If one of the pixel values differ significantly from the majority of
% the surrounding pixels, the pixel is treated as noise. The filtering 
% algorithm then replaces the noise pixel by the median values of the 
% surrounding pixels. This process repeats until all noise pixels in the
% image are removed.
design_name = 'mlhdlc_median_filter';
testbench_name = 'mlhdlc_median_filter_tb';
%%
% Review the MATLAB design:
edit(design_name);
%%
% <include>mlhdlc_median_filter.m</include>
%
% The MATLAB function is modular and uses several functions to filter the
% noise in the image.

%% Adaptive Filter MATLAB Test Bench
% A MATLAB test bench |mlhdlc_median_filter_tb| exercises the filter design by
% using a representative input range.
%
% Review the MATLAB test bench:
edit(testbench_name);
%%
% <include>mlhdlc_median_filter_tb.m</include>

%% Test the MATLAB Algorithm
% To avoid run-time errors, simulate the design with the test bench.
mlhdlc_median_filter_tb

%% Create a Folder and Copy Relevant Files
% Before you generate HDL code for the MATLAB design, copy the
% design and test bench files to a writeable folder. These commands
% copy the files to a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_med_filt']; 
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
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_img_pattern_noisy.png'), mlhdlc_temp_dir);

%% Accelerating the Design for Faster Simulation
% To simulate the test bench faster:
%
% 1. Create a MEX file by using MATLAB Coder(TM). The HDL Workflow Advisor 
% automates these steps when running fixed-point simulations of the design.
%    
%    codegen -o mlhdlc_median_filter -args {zeros(9,1), 0} mlhdlc_median_filter
%    [~, tbn] = fileparts(testbench_name);
%
% 2. Simulate the design by using the MEX file. When you run the test bench,
% HDL Coder uses the MEX file and runs the simulation faster.
% 
%    mlhdlc_median_filter_tb
%
% 3. Clean up the MEX file. 
%    
%    clear mex;
%    rmdir('codegen', 's');
%    delete(['mlhdlc_median_filter', '.', mexext]);

%% Create an HDL Coder Project
%
% 1. Create an HDL Coder project:
%
%   coder -hdlcoder -new mlhdlc_med_filt_prj
%
% 2. Add the file |mlhdlc_median_filter.m| to the project as the *MATLAB
% Function* and |mlhdlc_median_filter_tb.m| as the *MATLAB Test Bench*.
%
% 3. Click *Autodefine types* and use the recommended types for the inputs
% and outputs of the MATLAB function |mlhdlc_median_filter|.
%
% <<mlhdlc_adaptive_med_filter_prj.png>>
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run Fixed-Point Conversion and HDL Code Generation
%
% # Click the *Workflow Advisor* button to start the Workflow Advisor.
% # Right click the *HDL Code Generation* task and select *Run to selected task*. 
%
% A single HDL file |mlhdlc_median_filter_fixpt.vhd| is generated for the MATLAB design. 
% To examine the generated HDL code for the filter design, click the hyperlinks 
% in the Code Generation Log window.
%
% If you want to generate a HDL file for each function in your MATLAB design,
% in the *Advanced* tab of the *HDL Code Generation* task, select the 
% *Generate instantiable code for functions* check box. See also
% <docid:hdlcoder_ug#bt3r8wk-1 Generate Instantiable Code for Functions>.

%% Clean Up Generated Files
% To clean up the temporary project folder, run these commands:
%
%    mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%    mlhdlc_temp_dir = [tempdir 'mlhdlc_med_filt']; 
%    clear mex;
%    cd (mlhdlc_demo_dir);
%    rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
