%% Bisection Algorithm to Calculate Square Root of an Unsigned Fixed-Point Number
% This example shows how to generate HDL code from MATLAB(R) design implementing
% an bisection algorithm to calculate the square root of a number in fixed
% point notation.
% 
% Same implementation, originally using n-multipliers in HDL code, for wordlength n,
% under sharing and streaming optimizations, can generate HDL code with only 1
% multiplier demonstrating the power of MATLAB(R) HDL Coder optimizations.
% 
% The design of the square-root algorithm shows the  pipelining concepts
% to achieve a fast clock rate in resulting RTL design. Since this design is 
% already in fixed point, you don't need to run fixed-point conversion.
% 

%   Copyright 2013-2023 The MathWorks, Inc.

%% MATLAB Design
% 

% Design Sqrt
design_name = 'mlhdlc_sqrt';

% Test Bench for Sqrt
testbench_name = 'mlhdlc_sqrt_tb';

%%
% Lets look at the Sqrt Design
dbtype(design_name)

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sqrt']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

% copy files to the temp dir
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_sqrt_tb

%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_sqrt_prj
%
% Next, add the file 'mlhdlc_sqrt.m' to the project as the MATLAB
% Function and 'mlhdlc_sqrt_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run HDL Code Generation
%
% This design is already in fixed point and suitable for HDL code
% generation. It is not desirable to run floating point to fixed point
% advisor on this design.
%
% # Launch Workflow Advisor 
% # Under 'Define Input Types' Choose 'Keep original types' for the option 'Fixed-point conversion'
% # Under 'Optimizations' tab in 'RAM Mapping' box uncheck 'MAP persistent variables to RAMs'. We don't want the pipeline to be inferred as a RAM.
% # Optionally you may want to choose, under 'Optimizations' tab, 'Area
% Optimizations' and set 'Resource sharing factor' equal to wordlength (10
% here), select 'Stream Loops' under the 'Loop Optimizations' tab. Also don't forget to check 'Distributed Pipelining' when you enable the optimizations.
% # Click on the 'Code Generation' step and click 'Run'
%
% Examine the generated HDL code by clicking on the hyperlinks in the 
% Code Generation Log window.
%

%% Examine the Synthesis Results
%
% # Run the logic synthesis step with the following default options if you have
% ISE installed on your machine.
% # In the synthesis report, note the clock frequency reported by the synthesis
% tool without any optimization options enabled. 
% # Typically *timing performance* of this design
% using Xilinx ISE synthesis tool for the 'Virtex7' chip family, device
% 'xc7v285t', speed grade -3, to be around  *229MHz*, and a maximum combinatorial path delay:
% *0.406ns*.
% # Optimizations for this design (loop streaming and multiplier sharing) work to reduce resource
% usage, with a moderate trade-off on timing. For the particular
% word-length size in test bench you will see a reduction of *n* multipliers
% to *1*.
%

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_sqrt']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');


displayEndOfDemoMessage(mfilename)
