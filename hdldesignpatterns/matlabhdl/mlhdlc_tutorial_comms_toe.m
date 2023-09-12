%% Timing Offset Estimation
% This example shows how to generate HDL code from a basic lead-lag
% timing offset estimation algorithm implemented in MATLAB(R) code.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
%
% In wireless communication systems, receive data is oversampled at the RF
% front end. This serves several purposes, including providing sufficient
% sampling rates for receive filtering. 
% 
% However, one of the most important
% functions is to provide multiple sampling points on the received
% waveform such that data can be sampled near the maximum amplitude point
% in the received waveform. This example illustrates a basic lead-lag time
% offset estimation core, operating recursively. 
% 
% The generated hardware core for this design operates at 1/os_rate 
% where os_rate is the oversampled rate. That is, for 8 oversampled clock cycles 
% this core iterates once. The output is at the symbol rate.

design_name = 'mlhdlc_comms_toe';
testbench_name = 'mlhdlc_comms_toe_tb';

%%
% Let us take a look at the MATLAB(R) design.
type(design_name);

%%
type(testbench_name);


%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_toe']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);


%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_comms_toe_tb

%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_toe
%
% Next, add the file 'mlhdlc_comms_toe.m' to the project as the MATLAB
% Function and 'mlhdlc_comms_toe_tb.m' as the MATLAB Test Bench.
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
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_toe']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
