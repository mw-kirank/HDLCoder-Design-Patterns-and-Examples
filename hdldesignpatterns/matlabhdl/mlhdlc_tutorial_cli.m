%% Generate HDL Code from MATLAB Code Using the Command Line Interface
% This example shows how to use the HDL Coder(TM) command line
% interface to generate HDL code from MATLAB(R) code, including
% floating-point to fixed-point conversion and FPGA
% programming file generation.

%   Copyright 2012-2023 The MathWorks, Inc.

%%   Overview
%
% HDL code generation with the command-line interface has the following
% basic steps:
%
% # Create a |fixpt| coder config object. (Optional)
% # Create an |hdl| coder config object.
% # Set config object parameters. (Optional)
% # Run the codegen command to generate code.
%
% The HDL Coder command-line interface can use two coder config objects
% with the codegen command. The optional |fixpt| coder config object
% configures the floating-point to fixed-point conversion of your MATLAB
% code. The |hdl| coder config object configures HDL code generation and
% FPGA programming options.
%
% In this example, we explore different ways you can configure your
% floating-point to fixed-point conversion and code generation. 
%
% The example code implements a discrete-time integrator and its test bench.

%% Copy the Design and Test Bench Files Into a Temporary Folder
% Execute the following code to copy the design and test bench files
% into a temporary folder:

close all;
design_name = 'mlhdlc_dti';
testbench_name = 'mlhdlc_dti_tb';

mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_dti']; 

cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Basic Code Generation With Floating-Point to Fixed-Point Conversion
% 
% You can generate HDL code and convert the design from floating-point to
% fixed-point using the default settings. 
%
% You need only your design name, |mlhdlc_dti|, and test bench name,
% |mlhdlc_dti_tb|:

close all;

% Create a 'fixpt' config with default settings
fixptcfg = coder.config('fixpt'); 
fixptcfg.TestBenchName = 'mlhdlc_dti_tb'; 

% Create an 'hdl' config with default settings
hdlcfg = coder.config('hdl'); %#ok<NASGU> 

%%
% After setting up |fixpt| and |hdl| config objects, run the following
% codegen command to perform floating-point to fixed-point
% conversion, and generate HDL code.
%
%   codegen -float2fixed fixptcfg -config hdlcfg mlhdlc_dti

%%
% If your design already uses fixed-point types and
% functions, you can skip fixed-point conversion:
%
%   hdlcfg = coder.config('hdl'); % Create an 'hdl' config with default settings
%   hdlcfg.TestBenchName = 'mlhdlc_dti_tb';
%   codegen -config hdlcfg mlhdlc_dti

%%
% The rest of this example describes how to configure code generation using
% the |hdl| and |fixpt| objects.

%% Create a Floating-Point to Fixed-Point Conversion Config Object
% To perform floating-point to fixed-point conversion, you need a |fixpt|
% config object.
%
% Create a |fixpt| config object and specify your test bench name:

close all;
fixptcfg = coder.config('fixpt'); 
fixptcfg.TestBenchName = 'mlhdlc_dti_tb'; 
 
%% Set Fixed-Point Conversion Type Proposal Options
% The code generator can propose fixed-point types based on your
% choice of either word length or fraction length. These two options are
% mutually exclusive.
%
% Base the proposed types on a word length of |24|:
fixptcfg.DefaultWordLength = 24;
fixptcfg.ProposeFractionLengthsForDefaultWordLength = true; 

%% 
% Alternatively, you can base the proposed fixed-point types on fraction length. The
% following code configures the coder to propose types based on a fraction
% length of |10|:
%
%   fixptcfg.DefaultFractionLength = 10;
%   fixptcfg.ProposeWordLengthsForDefaultFractionLength = true; 

%% Set the Safety Margin
% The code generator increases the simulation data range on which it bases its
% fixed-point type proposal by the safety margin percentage. For example,
% the default safety margin is |4|, which increases the simulation data range
% used for fixed-point type proposal by |4%|.
% 
% Set the SafetyMargin to |10%|:
fixptcfg.SafetyMargin = 10;

%% Enable Data Logging
%
% The code generator runs the test bench with the design before and after
% floating-point to fixed-point conversion. You can enable
% simulation data logging to plot the quantization effects of the new
% fixed-point data types.
%
% Enable data logging in the |fixpt| config object:
fixptcfg.LogIOForComparisonPlotting = true; 

%% View the Numeric Type Proposal Report
% 
% Configure the code generator to launch the type proposal report once
% the fixed-point types have been proposed:
fixptcfg.LaunchNumericTypesReport = true;

%% Create an HDL Code Generation Config Object
% To generate code, you must create an |hdl| config object and set your test
% bench name:
hdlcfg = coder.config('hdl');
hdlcfg.TestBenchName = 'mlhdlc_dti_tb'; 

%% Set the Target Language
% You can generate either VHDL or Verilog code. HDL Coder generates VHDL
% code by default. To generate Verilog code:
hdlcfg.TargetLanguage = 'Verilog';

%% Generate HDL Test Bench Code
% Generate an HDL test bench from your MATLAB(R) test bench:
hdlcfg.GenerateHDLTestBench = true;

%% Simulate the Generated HDL Code Using an HDL Simulator
% If you want to simulate your generated HDL code using an HDL simulator,
% you must also generate the HDL test bench.
%
% Enable HDL simulation and use the ModelSim simulator:
hdlcfg.SimulateGeneratedCode = true;
hdlcfg.SimulationTool = 'ModelSim'; %  or 'ISIM'

%% Generate an FPGA Programming File
% You can generate an FPGA programming file if you have a synthesis tool
% set up. Enable synthesis, specify a synthesis tool, and specify an FPGA:

% Enable Synthesis.
hdlcfg.SynthesizeGeneratedCode = true;

% Configure Synthesis tool.
hdlcfg.SynthesisTool = 'Xilinx ISE'; %  or 'Altera Quartus II';
hdlcfg.SynthesisToolChipFamily = 'Virtex7';
hdlcfg.SynthesisToolDeviceName = 'xc7vh580t';
hdlcfg.SynthesisToolPackageName = 'hcg1155';
hdlcfg.SynthesisToolSpeedValue = '-2G';

%% Run Code Generation
% Now that you have your |fixpt| and |hdl| config objects set up, run the
% codegen command to perform floating-point to fixed-point
% conversion, generate HDL code, and generate an FPGA programming file:
%
%   codegen -float2fixed fixptcfg -config hdlcfg mlhdlc_dti

displayEndOfDemoMessage(mfilename)
