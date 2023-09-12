%% System Design with HDL Code Generation from MATLAB and Simulink
%
% This example shows how to generate a MATLAB Function block
% from a MATLAB(R) design for system simulation, code generation,
% and FPGA programming in Simulink(R).

%   Copyright 2012-2023 The MathWorks, Inc.

%% Introduction
% HDL Coder can generate HDL code from both MATLAB(R) and Simulink(R). The coder
% can also generate a Simulink(R) component, the MATLAB Function block, from your
% MATLAB code.
%
% This capability enables you to:
%
% # Design an algorithm in MATLAB;
% # Generate a MATLAB Function block from your MATLAB design;
% # Use the MATLAB component in a Simulink model of the system;
% # Simulate and optimize the system model;
% # Generate HDL code; and
% # Program an FPGA with the entire system design.
%
% In this example, you will generate a MATLAB Function block from
% MATLAB code that implements a FIR filter.

%% MATLAB Design
% The MATLAB code used in the example is a simple FIR filter.
% The example also shows a MATLAB testbench that exercises the filter.

design_name = 'mlhdlc_fir';
testbench_name = 'mlhdlc_fir_tb';

%%
%
% # Design: <matlab:edit('mlhdlc_fir') mlhdlc_fir>
% # Test Bench: <matlab:edit('mlhdlc_fir_tb') mlhdlc_fir_tb>

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_fir']; 

% Create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Simulate the Design
% To simulate the design with the test bench prior to
% code generation to make sure there are no runtime errors, enter the
% following command:
%
% mlhdlc_fir_tb

%% Create a New Project
% To create a new HDL Coder project, enter the following command:
%
%   coder -hdlcoder -new fir_project
%
% Next, add the file 'mlhdlc_fir.m' to the project as the MATLAB
% Function and 'mlhdlc_fir_tb.m' as the MATLAB Test Bench.
%
% Click the Workflow Advisor button to launch the HDL Workflow Advisor.

%% Enable the MATLAB Function Block Option
%
% To generate a MATLAB Function block from a MATLAB HDL design, you must
% have a Simulink license.
% If the following command returns '1', Simulink is
% available:
%
%   license('test', 'Simulink')
%
% In the HDL Workflow Advisor Advanced tab, enable the Generate MATLAB Function
% Block option.
%
% <<mlhdlc_tutorial_sl_integration.png>>
%

%% Run Floating-Point to Fixed-Point Conversion and Generate Code
% To generate a MATLAB Function block, you must also convert your design
% from floating-point to fixed-point. 
%
% Right-click the 
% 'Code Generation' step and choose the option 'Run to selected task' to 
% run all the steps from the beginning through HDL code generation. 


%% Examine the Generated MATLAB Function Block
%
% An untitled model opens after HDL code generation.  It has a MATLAB
% Function block containing the fixed-point MATLAB code from your MATLAB HDL
% design.  HDL Coder automatically applies settings to the model
% and MATLAB Function block so that they can simulate in Simulink and generate
% HDL code.
%
% To generate HDL code from the MATLAB Function block, enter the following command:
%
%   makehdl('untitled');
% 
% <<mlhdlc_tutorial_sl_integration_01.png>>
%
% You can rename and save the new block to use in a larger Simulink design.

%% Clean Up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fir']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
