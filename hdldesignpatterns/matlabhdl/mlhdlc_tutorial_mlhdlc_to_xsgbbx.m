%% Generate Xilinx System Generator for DSP Black Box from MATLAB HDL Design
%
% This example shows how to generate a Xilinx &reg; System Generator for DSP
% Black Box block from a MATLAB(R) HDL design.

%   Copyright 2012-2023 The MathWorks, Inc.

%% Introduction
% HDL Coder can generate a System Generator Black Box block and configuration
% file from your MATLAB HDL design.
% After designing an algorithm in MATLAB for HDL code generation, you can
% then integrate it into a larger system as a Xilinx System Generator Black
% Box block.
%
% HDL Coder places the generated Black Box block in a Xilinx System Generator
% (XSG) subsystem. XSG subsystems work with blocks from both Simulink(R) and
% Xilinx System Generator, so you can use the generated black box block to
% build a larger system for simulation and code generation.
 

%% MATLAB Design
% The MATLAB code in the example implements a simple FIR filter.
% The example also shows a MATLAB testbench that exercises the filter.

design_name = 'mlhdlc_fir';
testbench_name = 'mlhdlc_fir_tb';

%%
%
% # Design: <matlab:edit('mlhdlc_fir') mlhdlc_fir>
% # Test Bench: <matlab:edit('mlhdlc_fir_tb') mlhdlc_fir_tb>

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
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
% To simulate the design with the test bench to make sure there are no
% runtime errors before code generation, enter the following command:
%
% mlhdlc_fir_tb

%% Create a New Project From the Command Line
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new fir_project
%
% Next, add the file 'mlhdlc_fir.m' to the project as the MATLAB
% Function and 'mlhdlc_fir_tb.m' as the MATLAB Test Bench.
%
% Click the Workflow Advisor button to launch the HDL Workflow Advisor.

%% Generate a Xilinx System Generator for DSP Black Box
%
% To generate a Xilinx System Generator Black Box from a MATLAB HDL design,
% you must have Xilinx System Generator configured.  Enter the following
% command to check System Generator availability:
%
%   xlVersion
%
% In the Advanced tab of the Workflow Advisor, enable the Generate Xilinx
% System Generator Black Box option:
%
% <<mlhdlc_tutorial_xsg_integration.png>>
%
% To generate code compatible with a Xilinx System Generator Black Box,
% set: 
%
% * 'Clock input port' to 'clk'
% * 'Clock enable input port' to 'ce'
% * 'Drive clock enable at' to 'DUT base rate'
%
% <<mlhdlc_tutorial_xsg_integration_01.png>>

%% Run Fixed-Point Conversion and Generate Code
% Right-click the 'Code Generation' step and choose the 'Run to selected task'
% option to run all the steps from the beginning through HDL code generation. 


%% Examine the Generated Model and Config File
%
% A new model opens after HDL code generation. It contains a subsystem called DUT
% at the top level. 
%
% The DUT subsystem has an XSG subsystem called SysGenSubSystem, which contains:
%
% * A Xilinx System Generator Black Box block
% * A System Generator block
% * Gateway-in blocks
% * Gateway-out blocks
%
% <<mlhdlc_tutorial_xsg_integration_02.png>>
%
% Notice that in addition to the data ports, there is a reset port on the black
% box interface, while 'clk' and 'ce' are registered to System Generator by
% the Black Box configuration file.
%
% The configuration file and your new model are saved in the same directory
% with generated HDL code. You can open the configuration file by entering
% the following command:
%
%   edit('codegen/mlhdlc_fir/hdlsrc/mlhdlc_fir_FixPt_xsgbbxcfg.m');
%
% <<mlhdlc_tutorial_xsg_integration_03.png>>
%
% You can now use the generated Xilinx System Generator Black Box block and
% configuration file in a larger system design.

%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fir']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
