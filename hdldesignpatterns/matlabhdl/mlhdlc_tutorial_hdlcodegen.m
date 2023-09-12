%% Basic HDL Code Generation and FPGA Synthesis from MATLAB
% This example shows how to create a HDL Coder(TM) project, generate code 
% for your MATLAB(R) design, and synthesize the HDL code. In this example, you:
%
% # Create a MATLAB HDL Coder project.
% # Add the design and test bench files to the project.
% # Start the HDL Workflow Advisor for the MATLAB design.
% # Run fixed-point conversion and HDL code generation.
% # Generate a HDL test bench from the MATLAB test bench.
% # Verify the generated HDL code by using a HDL simulator. This
% example uses ModelSim(R) as the tool.
% # Synthesize the generated HDL code by using a synthesis tool. This
% example uses Xilinx(R) Vivado(R) as the tool.

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
% A MATLAB testbench |mlhdlc_sfir_tb| exercises the filter design by using a 
% representative input range. Review the MATLAB test bench
% |mlhdlc_sfir_tb|.
open(testbench_name);
%%
% <include>mlhdlc_sfir_tb.m</include>

%% Test the Original MATLAB Algorithm
% To avoid run-time errors, simulate the design by using the test bench.
mlhdlc_sfir_tb

%% Create a Folder and Copy Relevant Files
% To copy the example files into a temporary folder, run these commands:
design_name = 'mlhdlc_sfir';
testbench_name = 'mlhdlc_sfir_tb';
%%
% Create a temporary folder
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sfir']; 
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);
%%
% Copy the MATLAB files.
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Set Up HDL Simulator and Synthesis Tool Path
% If you want to synthesize the generated HDL code, before you use HDL Coder 
% to generate code, set up your synthesis tool path. To set up the path to 
% your synthesis tool, use the hdlsetuptoolpath function. For example, 
% if your synthesis tool is Xilinx Vivado:
%
%   hdlsetuptoolpath('ToolName','Xilinx Vivado','ToolPath',...
%                  'C:\Xilinx\Vivado\2018.3\bin\vivado.bat'); 
%
% You must have already installed Xilinx Vivado. To check your Xilinx Vivado
% synthesis tool setup, launch the tool by running this command:
%
%   !vivado
%
% If you want to simulate the generated HDL code by using a HDL test bench,
% you can use an HDL simulator such as ModelSim(R). You must have already
% installed the HDL simulator.

%% Create an HDL Coder Project
% To create an HDL Coder project:
%
% 1. Create a project by running this command:
%
%   coder -hdlcoder -new sfir_project
%
% 2. For *MATLAB Function*, add the MATLAB design |mlhdlc_sfir|. Add 
% |mlhdlc_sfir_tb.m| as the MATLAB test bench.
%
% 3. Click *Autodefine types* and use the recommended types for the MATLAB
% design. The code generator infers data types by running the test bench.
%
% <<mlhdlc_filespec_dialog.png>>

%% Create Fixed-Point Versions of Algorithm and Test Bench
%
% # Click the *Workflow Advisor* button to open the Workflow Advisor. You
% see that the *Define Input Types* task has passed.
% # Run the *Fixed-Point Conversion* task. The *Fixed-Point Conversion* tool 
% opens in the right pane.
%
% When you run fixed-point conversion, to propose fraction lengths for 
% floating-point data types, HDL Coder uses the *Default word length*. 
% In this tutorial, the *Default word length* is |14|. The advisor provides 
% a default *Safety Margin for Simulation Min/Max* of |0%|. The advisor 
% adjusts the range of the data by this safety factor. For example, 
% a value of |4| specifies that you want a range of at least |4| percent larger.
% See also <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_intro Floating-Point to Fixed-Point Conversion>.

%% Select Code Generation Options and Generate HDL Code
% Before you generate HDL code, if you want to deploy the code onto a target
% platform, specify the synthesis tool. In the *Code Generation Target* 
% task, leave *Workflow* to |Generic ASIC/FPGA| and specify |Xilinx Vivado| 
% as the *Synthesis Tool*. If you don't see the synthesis tool, click *Refresh list*. 
% Run this task. 
%
% In the *HDL Code Generation* task, by using the tabs on the right side of this
% task, you can specify additional code generation options.
%
% # By default, HDL Coder generates VHDL(R) code. To generate Verilog code, 
% in the *Target* tab, choose |Verilog| as the *Language*.
% # To generate a code generation report with comments and traceability links,
% in the *Coding style* tab, select *Include MATLAB source code as comments* 
% and 'Generate report*.
% # To optimize your design, you can use the distributed pipelining
% optimization. In the *Optimizations* tab, specify |1| for *Input pipelining*
% and *Output pipelining* and then select *Distribute pipeline registers*.
% To learn more, see <docid:hdlcoder_ug#btvea5o-1 Distributed Pipelining>.
% # Click *Run* to generate Verilog code. 
%
% Examine the log window and click the links to explore the generated code 
% and the reports.

%% Generate HDL Test Bench and Simulate the Generated Code
% HDL Coder generates a HDL test bench, runs the HDL test bench
% by using a HDL simulator, and verifies whether the HDL simulation 
% matches the numerics and latency of the fixed-point MATLAB simulation.
%
% To generate a HDL test bench and simulate the generated code, in the
% *HDL Verification > Verify with HDL Test Bench* task:
%
% # In the *Output Settings* tab, select *Generate HDL test bench*. 
% # To simulate the generated test bench, set the *Simulation Tool* to
% |ModelSim|. You must have already installed ModelSim. 
% # To specify generation of HDL test bench code and test bench data in separate 
% files, in the *Test Bench Options* tab, select *Multi-file test bench*. 
% # Click the *Run* button. 
%
% The task generates an HDL test bench, then simulates the fixed-point design 
% by using the selected simulation tool, and generates a compilation report 
% and a simulation report.

%% Synthesize Generated HDL Code
% HDL Coder synthesizes the HDL code on the target platform and generates
% area and timing reports for your design based on the target device that 
% you specify.
%
% To synthesize the generated HDL code:
%
% 1. Run the *Create project* task.
%
% This task creates a Xilinx Vivado synthesis project for the HDL code. HDL Coder 
% uses this project in the next task to synthesize the design.
%
% 2. Select and run the *Run Synthesis* task.
%
% This task launches the synthesis tool in the background, opens the
% synthesis project, compiles the HDL code, synthesizes the design, and
% generates netlists and area and timing reports.
%
% 3. Select and run the *Run Implementation* task.
%
% This task launches the synthesis tool in the background, runs place and
% route on the design, and generates pre- and post-route timing information for
% use in critical path analysis and back annotation of your source model.

%% Clean Up Generated Files
% To clean up the temporary project folder, run these commands:
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_sfir']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
