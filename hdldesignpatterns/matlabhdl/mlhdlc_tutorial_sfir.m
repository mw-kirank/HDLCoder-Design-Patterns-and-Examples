%% Getting Started with MATLAB to HDL Workflow
% This example shows how to create a HDL Coder(TM) project and generate code
% from your MATLAB(R) design. In this example, you:
%
% # Create a MATLAB HDL Coder project.
% # Add the design and test bench files to the project.
% # Start the HDL Workflow Advisor for the MATLAB design.
% # Run fixed-point conversion and HDL code generation.

%   Copyright 2011-2023 The MathWorks, Inc.

%% FIR Filter MATLAB Design
% The MATLAB design |mlhdlc_sfir| is a simple symmetric FIR filter.
design_name = 'mlhdlc_sfir';
testbench_name = 'mlhdlc_sfir_tb';
%%
% Review the MATLAB design.
open(design_name);
%%
% <include>mlhdlc_sfir.m</include>
%
%% FIR Filter MATLAB Test Bench
% A MATLAB testbench |mlhdlc_sfir_tb| exercises the filter design.
open(testbench_name);
%%
% <include>mlhdlc_sfir_tb.m</include>

%% Test the MATLAB Algorithm
% To avoid run-time errors, simulate the design by using the test bench.
mlhdlc_sfir_tb

%% Create a Folder and Copy Relevant Files
% To copy the example files into a temporary folder, run these commands:
design_name = 'mlhdlc_sfir';
testbench_name = 'mlhdlc_sfir_tb';
%%
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sfir']; 
%%
% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Create an HDL Coder Project
% To create an HDL Coder project:
%
% 1. In the MATLAB Editor, on the *Apps* tab, select *HDL Coder. 
% Enter |sfir_project| as *Name* of the project.
%
% To create a project from the MATLAB command prompt, run this command:
%
%   coder -hdlcoder -new sfir_project
%
% A |sfir_project.prj| file is created in the current folder. 
%
% 2. For *MATLAB Function*, click the *Add MATLAB function* link and select
% the FIR filter MATLAB design |mlhdlc_sfir|. Under the *MATLAB Test Bench*
% section, click *Add files* and add the MATLAB test bench
% |mlhdlc_sfir_tb.m|.
%
% 3. Click *Autodefine types* and use the recommended types for the MATLAB
% design. The code generator infers the input types from the MATLAB test bench.
%
% <<mlhdlc_filespec_dialog.png>>

%% Run Fixed-Point Conversion and HDL Code Generation
% 
% # Click the *Workflow Advisor* button to start the HDL Workflow Advisor.
% # Right-click the *HDL Code Generation* task and select *Run to selected task*.
%
% The code generator runs the Workflow Advisor tasks to generate HDL code
% for the filter design. The steps:
%
% * Translate your floating-point MATLAB design to a fixed-point design.
% To examine the generated fixed-point code from the floating-point design,
% click the *Fixed-Point Conversion* task. The generated fixed-point MATLAB code opens
% in the MATLAB editor. For details, see 
% <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_intro>.
%
% * Generate HDL code from the fixed-point MATLAB design.
% By default, HDL Coder generates VHDL code. To examine the generated HDL code, 
% click the *HDL Code Generation* task and then click the hyperlink to 
% |mlhdlc_sfir_fixpt.vhd| in the Code Generation Log window. To generate Verilog
% code, in the *HDL Code Generation* task, select the *Advanced* tab, and
% set *Language* to |Verilog|. For more information and to learn how to
% specify code generation options, see 
% <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_intro>.

%% Clean Up Generated Files
% To clean up the temporary project folder, run these commands:
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_sfir']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
