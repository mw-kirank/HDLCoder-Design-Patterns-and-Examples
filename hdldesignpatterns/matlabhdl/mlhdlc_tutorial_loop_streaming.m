%% Loop Streaming to Reduce Area
% This example shows how to use the design-level loop streaming
% optimization in HDL Coder(TM) to optimize area. 

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
%
% A MATLAB(R) for loop generates a FOR_GENERATE loop in VHDL. Such loops
% are always spatially unrolled for execution 
% in hardware. In other words, the body of the software loop is replicated 
% as many times in hardware as the number of loop iterations. 
% This results in inefficient area usage. 
%
% The loop streaming optimization creates an alternative 
% implementation of a software loop, where the body of the loop is 
% shared in hardware. Instead of spatially replicating 
% copies of the loop body, HDL Coder(TM) creates a single hardware 
% instance of the loop body that is time-multiplexed across loop iterations. 

%% MATLAB Design
% The MATLAB code used in this example implements a simple FIR filter.
% This example also shows a MATLAB testbench that exercises the filter.

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
mlhdlc_fir_tb

%% Creating a New Project From the Command Line
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new fir_project
%
% Next, add the file 'mlhdlc_fir.m' to the project as the MATLAB
% Function and 'mlhdlc_fir_tb.m' as the MATLAB Test Bench.
%
% Launch the Workflow Advisor.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.

%% Turn On Loop Streaming
%
% The loop streaming optimization in HDL Coder converts software loops
% (either written explicitly using a for-loop statement, or inferred loops
% from matrix/vector operators) to area-friendly hardware loops.
%
% <<mlhdlc_loop_streaming_option.png>>

%% Run Fixed-Point Conversion and HDL Code Generation
% Right-click the 
% 'Code Generation' step. Choose the option 'Run to selected task' to 
% run all the steps from the beginning through HDL code generation. 


%% Examine the Generated Code
% When you synthesize the design with the loop streaming optimization, you see a 
% reduction in area resources in the resource report. Try generating HDL
% code with and without the optimization.
%
% The resource report without the loop streaming optimization:
%
% <<mlhdlc_wo_loop_streaming.png>>
%
% The resource report with the loop streaming optimization enabled:
%
% <<mlhdlc_w_loop_streaming.png>>


%% Known Limitations
%
% Loops will be streamed only if they are regular nested loops. A 
% regular nested loop structure is defined as one where: 
%
% * None of the loops in any level of nesting appear in a conditional flow region, 
% i.e. no loop can be embedded within if-else or switch-else regions. 
% * Loop index variables are monotonically increasing. 
% * Total number of iterations of the loop structure is non-zero.
% * There are no back-to-back loops at the same level of the nesting hierarchy. 

%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fir']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
