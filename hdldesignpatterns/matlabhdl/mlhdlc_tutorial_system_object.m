%% HDL Code Generation from System Objects
% This example shows how to generate HDL code from MATLAB(R) code that
% contains System objects.

%   Copyright 2011-2023 The MathWorks, Inc.

%% MATLAB Design
% The MATLAB code used in this example implements a simple symmetric FIR
% filter and uses the dsp.Delay System object to model state.
% This example also shows a MATLAB test bench that exercises the filter.

design_name = 'mlhdlc_sysobj_ex';
testbench_name = 'mlhdlc_sysobj_ex_tb';

%%
% Let us take a look at the MATLAB design.
type(design_name);

%%
type(testbench_name);

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sysobj_intro']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Simulate the Design
% Simulate the design with the test bench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_sysobj_ex_tb

%% Create a New HDL Coder(TM) Project
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new mlhdlc_sysobj_prj
%
% Next, add the file 'mlhdlc_sysobj_ex.m' to the project as the MATLAB
% Function and 'mlhdlc_sysobj_ex_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch the Workflow Advisor. In the Workflow Advisor, right-click the 
% 'Code Generation' step. Choose the option 'Run to selected task' to 
% run all the steps from the beginning through HDL code generation. 
%
% Examine the generated HDL code by clicking the links in the 
% log window.

%% Supported System objects
% For a list of System objects supported for HDL code generation, see
% <docid:hdlcoder_ug#buku0v7-1>.

%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_sysobj_intro']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
