%% Generating Modular HDL Code for Functions
% This example shows how to generate modular HDL code from MATLAB(R) code that
% contains functions.
%
% By default, HDL Coder(TM) inlines the body of all MATLAB functions that are 
% called inside the body of the top-level design function. This inlining results 
% in the generation of a single file that contains the HDL code for the functions.
% To generate modular HDL code, use the *Generate instantiable code for functions*
% setting. When you enable this setting, HDL Coder generates a single VHDL(R) 
% entity or Verilog(R) module for each function.

%   Copyright 2011-2023 The MathWorks, Inc.

%% LMS Filter MATLAB Design
% The MATLAB design used in the example is an implementation of an LMS (Least
% Mean Squares) filter. The LMS filter is a class of adaptive filter that
% identifies an FIR filter signal that is embedded in the noise. The LMS
% filter design implementation in MATLAB consists of a top-level function
% |mlhdlc_lms_fcn| that calculates the optimal filter coefficients to
% reduce the difference between the output signal and the desired signal.
design_name = 'mlhdlc_lms_fcn';
testbench_name = 'mlhdlc_lms_fir_id_tb';
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
open(testbench_name);
%%
% <include>mlhdlc_lms_fir_id_tb.m</include>

%%  Test the MATLAB Algorithm
% To avoid run-time errors, simulate the design with the test bench.
mlhdlc_lms_fir_id_tb
%% Create a Folder and Copy Relevant Files
% Before you generate HDL code for the MATLAB design, copy the
% design and test bench files to a writeable folder. These commands
% copy the files to a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_fcn_partition']; 
%%
% Create a temporary folder and copy the MATLAB files.
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
%   coder -hdlcoder -new mlhdlc_fcn_partition
%
% 2. Add the file |mlhdlc_lms_fcn.m| to the project as the *MATLAB
% Function* and |mlhdlc_lms_fir_id_tb.m| as the *MATLAB Test Bench*.
%
% 3. Click *Autodefine types* to use the recommended types for the inputs
% and outputs of the MATLAB function |mlhdlc_lms_fcn|.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.
%
% <<mlhdlc_lms_fir_id_new_hdl_project.png>>

%% Run Fixed-Point Conversion and HDL Code Generation
%
% # Click the *Workflow Advisor* button to start the Workflow Advisor.
% # Right click the *HDL Code Generation* task and select *Run to selected task*. 

%%
% A single HDL file |mlhdlc_lms_fcn_FixPt.vhd| is generated for the MATLAB design. 
% The VHDL code for all functions in the MATLAB design is inlined into this
% file.

%% Generate Instantiable HDL Code
%
% # In the *Advanced* tab, select the *Generate instantiable code for
% functions* check box.
% # Click the *Run* button to rerun the *HDL Code Generation* task.
%
% You see multiple HDL files that contain the generated code for the
% top-level function and the functions that are called inside the top-level
% function. See also <docid:hdlcoder_ug#bt3r8wk-1 Generate Instantiable 
% Code for Functions>.

%% Control Inlining For Each Function
% In some cases, you may want to inline the HDL code for helper functions and
% utilities and then instantiate them. To locally control inlining of
% such functions, use the |coder.inline| pragma in the MATLAB code. 
%
% To inline a function in the generated code, place this
% directive inside that function:
%
%   coder.inline('always')
%
% To prevent inlining of a function in the generated code, place this
% directive inside that function:
%
%   coder.inline('never')
%
% To let the code generator determine whether to inline a function in
% the generated code, place this directive inside that function:
%
%   coder.inline('default')
%
% To learn how to use |coder.inline| pragma, enter:
%
%   help coder.inline

%% Limitations for Instantiating HDL Code from Functions
%
% * Function calls inside conditional expressions and for loops are inlined
% and are not instantiated.
% * Functions with states are inlined.

%% Clean Up Generated Files
% To clean up the temporary project folder, run these commands:
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fcn_partition']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
