%% HDL Code Generation for LMS Filter
% This example shows how to generate HDL code from a MATLAB(R) design that 
% implements an LMS filter. The example also illustrates how to design a 
% test bench that cancels out the noise signal by using this filter.

%   Copyright 2011-2023 The MathWorks, Inc.

%% LMS Filter MATLAB Design
% The MATLAB design used in the example is an implementation of an LMS (Least
% Mean Squares) filter. The LMS filter is a class of adaptive filter that
% identifies an FIR filter signal that is embedded in the noise. The LMS
% filter design implementation in MATLAB consists of a top-level function
% |mlhdlc_lms_fcn| that calculates the optimal filter coefficients to
% reduce the difference between the output signal and the desired signal.
design_name = 'mlhdlc_lms_fcn';
testbench_name = 'mlhdlc_lms_noise_canceler_tb';

%%
% Review the MATLAB design:
open(design_name);
%%
% <include>mlhdlc_lms_fcn.m</include>
%
% The MATLAB function is modular and uses functions:
%
% * |mtapped_delay_fcn| to calculate delayed versions of the input signal
% in vector form.
% * |mtreesum_fcn| to calculate the sum of the applied weights in a 
% tree structure. The individual sum is calculated by using a |vsum|
% function.
% * |update_weight_fcn| to calculate the updated filter weights based on
% the least mean square algorithm.

%% LMS Filter MATLAB Test Bench
% Review the MATLAB test bench:
open(testbench_name)
%%
% <include>mlhdlc_lms_noise_canceler_tb.m</include>

%%  Test the MATLAB Algorithm
% To avoid run-time errors, simulate the design with the test bench.
mlhdlc_lms_noise_canceler_tb

%% Create a Folder and Copy Relevant Files
% Before you generate HDL code for the MATLAB design, copy the
% design and test bench files to a writeable folder. These commands
% copy the files to a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_lms_nc']; 
%%
% create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);
%%
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Create an HDL Coder Project
% To generate HDL code from a MATLAB design:
%
% 1. Create a HDL Coder project:
%
%   coder -hdlcoder -new mlhdlc_lms_nc
%
% 2. Add the file |mlhdlc_lms_fcn.m| to the project as the *MATLAB
% Function* and |mlhdlc_lms_noise_canceler_tb.m| as the *MATLAB Test Bench*.
%
% 3. Click *Autodefine types* to use the recommended types for the inputs
% and outputs of the MATLAB function |mlhdlc_lms_fcn|.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 
%
% <<mlhdlc_lms_noise_canceler_project.png>>

%% Run Fixed-Point Conversion and HDL Code Generation
%
% # Click the *Workflow Advisor* button to start the Workflow Advisor.
% # Right click the *HDL Code Generation* task and select *Run to selected task*. 
%
% A single HDL file |mlhdlc_lms_fcn_FixPt.vhd| is generated for the MATLAB design. 
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
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_lms_nc'];  
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
