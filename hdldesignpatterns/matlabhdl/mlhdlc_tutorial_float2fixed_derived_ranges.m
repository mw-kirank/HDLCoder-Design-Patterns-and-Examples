%% Fixed-Point Type Conversion and Derived Ranges
%
% This example shows how to achieve your desired numerical accuracy when
% converting fixed-point MATLAB(R) code to floating-point code using static
% range analysis which helps to compute derived ranges of the variables
% from design ranges.
%

% Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
% The floating-point to fixed-point conversion workflow in HDL Coder(TM)
% includes the following steps:
%
% # Verify the floating-point design is compatible for code generation.
% # Compute fixed-point types based on the simulation of the testbench.
% # Generate readable and traceable fixed-point MATLAB(R) code.
% # Verify the generated fixed-point design.
%
% However, the fixed-point types proposed from the simulation depends on
% the quality of the testbench. Sometimes it is hard to write testbenches
% which completely cover paths of the design representing full design
% ranges of all the variables. Static analysis based workflow can be used
% in such cases to compute derived ranges from design ranges.

%%
% This tutorial uses a symmetric FIR filter whose output signal is
% integrated over time.

%% MATLAB Design
% The MATLAB code used in this example implements a simple Kalman filter. This
% example also contains a MATLAB testbench that exercises the filter.

design_name = 'mlhdlc_dti';
testbench_name = 'mlhdlc_dti_tb';

%%
%
% # MATLAB Design: <matlab:edit('mlhdlc_dti') mlhdlc_dti>
% # MATLAB testbench: <matlab:edit('mlhdlc_dti_tb') mlhdlc_dti_tb>
%

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_flt2fix_dmm']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Simulate the Design
% Simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_dti_tb

%% Create a New HDL Coder Project
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new flt2fix_project_dmm
%
% Next, add the file 'mlhdlc_dti.m' to the project as the MATLAB
% Function and 'mlhdlc_dti_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.

%% Fixed-Point Code Generation Workflow
% Perform the following tasks before moving on to the fixed-point type proposal
% step:
%
% # Click the 'Workflow Advisor' button to launch the HDL Workflow Advisor.
% # Choose 'Convert to fixed-point at build time' for the 'Fixed-point conversion' option.
% # Click 'Run' button to define input types for the design from the testbench.
% # Select the 'Fixed-Point Conversion' workflow step.
% # Click 'Analyze' to execute the instrumented floating-point simulation.
%
% Refer to <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_intro> 
% for a more complete tutorial on these steps.

%% Determine the Initial Fixed Point Types
% After instrumented floating-point simulation completes, you will see
% 'Fixed-Point Types are proposed' based on the simulation results.
%
% At this step fixed-point types for each variable in the design based on
% the recorded min/max values of the floating point variables and user
% input.
%
% Observe the simulation range of the variable 'is_clipped' in the
% function 'mlhdlc_dti'. You will notice that the simulation range of this
% variable is a constant value 0. However, if you can observe the code to
% see that the variable can take values from -1 to -1.
%
% The ranges for the variable can be fixed by updating the testbench.
% However, it may be desirable to compute program ranges through static
% analysis.

%% Entering Design Ranges and Computing Derived Ranges
% In this step you can specify design ranges and compute derived ranges
% through static analysis. Enable derived range analysis by clicking the
% 'analyze ranges using derived range analysis' checkbox in the 'Analyze'
% button's menu. The tool will then  prompt you to specify design ranges
% for the inputs variables in the Static Min and Static Max columns.
%
% <<mlhdlc_flt2fix_dmm_step1.png>>
%
% There are multiple ways you can enter design ranges.
%
% # You can manually edit the 'Static Min' and 'Static Max' entries in the
% table and specify design ranges.
% # You can copy the Sim Min and Sim Max for a variable via right-clicking
% on the table cell (or)
% # You can Lock or Specify the Output type to be used as the design range
%
% <<mlhdlc_flt2fix_dmm_step2.png>>
%
% Once all the necessary design ranges are specified you can click on the
% 'Analyze' button to use derived range analysis.
%
% <<mlhdlc_flt2fix_dmm_step3.png>>
%
% Notice that the derived range of the variable now includes values taken
% in all paths of the control flow.

%% Insufficient design ranges
%
% Sometimes specifying ranges for input variables alone may not be
% sufficient for certain designs. For example in a MATLAB design
% implementing a counter using a persistent variable, the range of the
% variable depends on number of times the design is called. In such
% situations you will see computed derived static ranges for the variable
% reported as -Inf or +Inf. When these imprecise ranges appear please
% consider specifying ranges for such persistent variables.

%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_flt2fix']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
