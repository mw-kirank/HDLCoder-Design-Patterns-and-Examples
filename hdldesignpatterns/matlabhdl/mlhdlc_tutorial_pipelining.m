%% Distributed Pipelining for Clock Speed Optimization
% This example shows how to use the distributed pipelining and loop
% unrolling optimizations in HDL Coder to optimize clock speed. 

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
% Distributed pipelining is a design-wide optimization supported by HDL Coder 
% for improving clock frequency. When you turn on the
% 'Distribute Pipeline Registers' option in HDL Coder, the
% coder redistributes the input and output pipeline registers of the 
% top level function along with other registers in the design 
% in order to minimize the combinatorial logic between registers 
% and thus maximize the clock speed of the chip synthesized from the generated 
% HDL code.
%
% Consider the following example design of a FIR filter. The 
% combinatorial logic from an input or a register to an output or another register
% contains a sum of products. Loop unrolling and distributed pipelining moves 
% the output registers at the design level to reduce the amount of 
% combinatorial logic, thus increasing clock speed.
 

%% MATLAB(R) Design
% The MATLAB code used in the example is a simple FIR filter.
% The example also shows a MATLAB test bench that exercises the filter.

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
% Simulate the design with the testbench prior to code generation to make
% sure there are no run-time errors. 
mlhdlc_fir_tb

%% Create a Fixed-Point Conversion Config Object
% To perform fixed-point conversion, you need a 'fixpt'
% config object.
%
% Create a 'fixpt' config object and specify your test bench name:
close all;
fixptcfg = coder.config('fixpt'); 
fixptcfg.TestBenchName = 'mlhdlc_fir_tb'; 

%% Create an HDL Code Generation Config Object
%
% To generate code, you must create an 'hdl' config object and set your test
% bench name:
hdlcfg = coder.config('hdl');
hdlcfg.TestBenchName = 'mlhdlc_fir_tb'; 

%% Distributed Pipelining
%
% To increase the clock speed, the user can set a number of input and output
% pipeline stages for any design. In this particular example Input
% pipelining option is set to '1' and Output pipelining option is set to
% '20'. Without any additional options turned on these settings will add one
% input pipeline register at all input ports of the top level design and
% 20 output pipeline registers at each of the output ports.
%
% If the option 'Distribute pipeline registers' is enabled, 
% HDL Coder tries to reposition the registers to achieve the best 
% clock frequency.
%
% In addition to moving the input and output pipeline registers, HDL Coder also
% tries to move the registers modeled internally in the design using
% persistent variables or with system objects like dsp.Delay.
%
% Additional opportunities for improvements become available if you unroll
% loops. The 'Unroll Loops' option unrolls explicit for-loops in MATLAB
% code in addition to implicit for-loops that are inferred for vector and
% matrix operations. 'Unroll Loops' is necessary for this example to do
% distributed pipelining.
hdlcfg.InputPipeline = 1;
hdlcfg.OutputPipeline = 20;
hdlcfg.DistributedPipelining = true;
hdlcfg.LoopOptimization = 'UnrollLoops';

%% Examine the Synthesis Results
%
% If you have ISE installed on your machine, run the logic synthesis step
% 
%   hdlcfg.SynthesizeGeneratedCode = true;
%   codegen -float2fixed fixptcfg -config hdlcfg mlhdlc_fir
%
% View the result report 
%
%   edit codegen/mlhdlc_fir/hdlsrc/ise_prj/mlhdlc_fir_fixpt_syn_results.txt
%
% In the synthesis report, note the clock frequency reported by the synthesis
% tool.  When you synthesize the design with the loop unrolling and distributed
% pipelining options enabled, you see a significant clock frequency increase 
% with pipelining options turned on.
%

%% Clean Up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fir']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
