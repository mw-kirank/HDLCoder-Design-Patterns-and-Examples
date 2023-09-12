%% HDL Code Generation from A Non-Restoring Square Root System Object
% This example shows how to check, generate and verify HDL code from
% MATLAB(R) code that instantiates a non-restoring square root system object.

%   Copyright 2013-2023 The MathWorks, Inc.

%% MATLAB Design
% The MATLAB code used in this example is a non-restoring square root
% engine suitable for implementation in an FPGA or ASIC. The engine uses a
% multiplier-free minimal area implementation based on [1]
% decision convolutional decoding, implemented as a System object.
% This example also shows a MATLAB test bench that tests the engine.

design_name = 'mlhdlc_sysobj_nonrestsqrt.m';
testbench_name = 'mlhdlc_sysobj_nonrestsqrt_tb.m';
sysobj_name = 'mlhdlc_msysobj_nonrestsqrt.m';

%%
% Let us take a look at the MATLAB design.
type(design_name);

%%
type(testbench_name);


%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_so_nonrestsqrt']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, design_name), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, testbench_name), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, sysobj_name), mlhdlc_temp_dir);


%% Simulate the Design
% Simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_sysobj_nonrestsqrt_tb


%% Hardware Implementation of the Non-Restoring Square Root Algorithm
% This algorithm implements the square root operation in a minimal area by
% using a single adder/subtractor with no mux (compared to a restoring
% algorithm that requires a mux). The square root is calculated using
% a series of shifts and adds/subs, so uses no multipliers (compared to
% other implementations which require a multiplier).
%
% The overall architecture of the algorithm is shown below, as described in
% [1].
% 
% <<mlhdlc_nonrestsqrt_arch.png>>
%
% This implementation of the algorithm uses a minimal area approach that
% requires multiple cycles to calculate each result. The overall
% calculation time can be approximated as [Input Word Length / 2], with a
% few cycles of overhead to load the incoming data.

%% Create a New HDL Coder Project
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new mlhdlc_nonrestsqrt
%
% Next, add the file 'mlhdlc_sysobj_nonrestsqrt.m' to the project as the MATLAB
% function and 'mlhdlc_sysobj_nonrestsqrt_tb.m' as the MATLAB test bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Skip Fixed-Point Conversion
% As the design is already in fixed-point, we do not need to perform
% automatic conversion.
%
% Launch the HDL Advisor and choose 'Keep original types' on the option 
% 'Fixed-point conversion:'.
%
% <<mlhdlc_workflow_dlg_skip_flat2fix.png>>
%

%% Run HDL Code Generation
% Launch the Workflow Advisor. In the Workflow Advisor, right-click the 
% 'Code Generation' step and choose the option 'Run to selected task' to 
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
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_so_nonrestsqrt']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');


%% References
% [1] Li, Y. and Chu, W. (1996) "A New Non-Restoring Square Root Algorithm
% and Its VLSI Implementations". IEEE International Conference on Computer
% Design: VLSI in Computers and Processors, ICCD '96 Austin, Texas USA (7-9
% October, 1996), pp. 538-544. doi: 10.1109/ICCD.1996.563604

displayEndOfDemoMessage(mfilename)
