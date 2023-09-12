%% Generate HDL Code from MATLAB Functions Using Automated Lookup Table Generation
% This example shows HDL code generation from a floating-point MATLAB(R) design 
% that is not ready for code generation in two steps. Use float2fixed conversion process to generate
% a lookup table based MATLAB function replacements. Use the new MATLAB replacement function to generate the HDL code.

%   Copyright 2014-2023 The MathWorks, Inc.

%% Introduction
% The MATLAB code used in the example is an implementation of a variable
% exponent function.
%

%% MATLAB Design
% 
design_name = 'mlhdlc_replacement_exp';
testbench_name = 'mlhdlc_replacement_exp_tb';

%%
% Examine the MATLAB design.
dbtype(design_name)

%% Simulate the Design
% It is a good practice to simulate the design with the test bench prior to
% code generation to make sure there are no run-time errors.
mlhdlc_replacement_exp_tb

%%
%
% * MATLAB Design: <matlab:edit('mlhdlc_replacement_exp') mlhdlc_replacement_exp>
% * MATLAB testbench: <matlab:edit('mlhdlc_replacement_exp_tb') mlhdlc_replacement_exp_tb>
%

%% 
% Open the design function mlhdlc_european_call by clicking the preceding link to
% see the use of unsupported fixed-point functions like |log|
% and |exp|.

%% Create a Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = fullfile(tempdir(),'mlhdlc_replacement_exp'); 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

% 
% The design is in the file |mlhdlc_replacement_exp.m|. The MATLAB test bench is in the file
% |mlhdlc_replacement_exp_tb.m|, which you can run separately. 
% 

%%  Generate HDL Code Using Implicit Fixed-Point Conversion
% 
% Your design is in the file |mlhdlc_replacement_exp.m| where the exponent
% function is calculated. The MATLAB test bench is in the file
% |mlhdlc_replacement_exp_tb.m|, which you can run separately.
%
% Run the following code as |runme.m| file to execute code generation.
%         
%    Set up the path to your installed synthesis tool. This example uses Vivado(R). 
%    hdlsetuptoolpath('ToolName', 'Xilinx Vivado', 'ToolPath', 'C:\Xilinx\Vivado\2019.1\bin\vivado.bat');
%   
%    clear design_name testbench_name fxpCfg hdlcfg interp_degree
%    design_name = 'mlhdlc_replacement_exp';
%    testbench_name = 'mlhdlc_replacement_exp_tb';
%    
%    interp_degree = 0;
%    
%    %%    fixed point converter config
%    fxpCfg = coder.config('fixpt');
%    fxpCfg.TestBenchName = 'mlhdlc_replacement_exp_tb';
%    fxpCfg.TestNumerics = true;
%    
%    %    specify this - for optimized HDL
%    fxpCfg.DefaultWordLength = 10;
%    
%    %%    exp - replacement config
%    mathFcnGenCfg = coder.approximation('exp');
%    %    generally use to increase accuracy; specify this as power of 2 for optimized HDL
%    mathFcnGenCfg.NumberOfPoints = 1024;
%    mathFcnGenCfg.InterpolationDegree = interp_degree; %         can be 0,1,2, or 3
%    fxpCfg.addApproximation(mathFcnGenCfg);
%    
%    %%    HDL config object
%    hdlcfg = coder.config('hdl');
%    
%    hdlcfg.TargetLanguage = 'Verilog';
%    
%    hdlcfg.DesignFunctionName = design_name;
%    hdlcfg.TestBenchName = testbench_name;
%    hdlcfg.GenerateHDLTestBench=true;
%    
%    hdlcfg.SimulateGeneratedCode=true;
%    
%    %If you choose VHDL set the ModelSim compile options as well
%    %    hdlcfg.TargetLanguage = 'Verilog';
%    %    hdlcfg.HDLCompileVHDLCmd = 'vcom %s %s -noindexcheck \n';
%    
%    hdlcfg.ConstantMultiplierOptimization = 'auto'; %optimize out any multipliers from interpolation
%    hdlcfg.PipelineVariables = 'y u idx_bot x x_idx';%    
%    
%    hdlcfg.InputPipeline = 2;
%    hdlcfg.OutputPipeline = 2;
%    hdlcfg.RegisterInputs = true;
%    hdlcfg.RegisterOutputs = true;
%    
%    hdlcfg.SynthesizeGeneratedCode = true;
%    hdlcfg.SynthesisTool = 'Xilinx ISE';
%    hdlcfg.SynthesisToolChipFamily = 'Virtex7';
%    hdlcfg.SynthesisToolDeviceName = 'xc7vh580t';
%    hdlcfg.SynthesisToolPackageName = 'hcg1155';
%    hdlcfg.SynthesisToolSpeedValue = '-2G';
%    
%    %codegen('-config',hdlcfg)
%    
%    codegen('-float2fixed',fxpCfg,'-config',hdlcfg,'mlhdlc_replacement_exp')
%       
%    %If you only want to do fixed point conversion and stop/examine the
%    %intermediate results you can use,
%      
%    %only F2F conversion
%    codegen('-float2fixed',fxpCfg,'mlhdlc_replacement_exp')
%
% 
% *Recommendations to generate high-clockrate circuits*
% 
% * Use the number of points for replacement functions as a power 
% * Set the *ConstantMultiplierOptimization* to *Auto* to allow HDL Coder 
% to choose which Constant Multiplier Optimization yields the most 
% area-efficient implementation in the generated HDL code. For more information, 
% see <docid:hdlcoder_ug#btvp74n-1 Constant Multiplier Optimization>. 
% * Use pipelined variables in HDL Code generation to minimize the clock delays 
% and improve circuit frequency.
% 
%% Output and Iterative Improvements
% 
% Once you run the |runme.m| script, the following output from
% fixpt converter and HDL Coder appears. The fixed-point conversion is 
% completed with the appropriate function replacements as: 
% 
%    ============= Step1: Analyze floating-point code ==============
%    
%    Input types not specified, inferring types by simulating the test bench.
%    
%    ============= Step1a: Verify Floating Point ==============
%    
%    ### Analyzing the design 'mlhdlc_replacement_exp'
%    ### Analyzing the test bench(es) 'mlhdlc_replacement_exp_tb'
%    ### Begin Floating Point Simulation (Instrumented)
%    ### Floating Point Simulation Completed in   1.8946 sec(s)
%    ### Elapsed Time:             2.8361 sec(s)
%    
%    ============= Step2: Propose Types based on Range Information ==============
%    
%    
%    ============= Step3: Generate Fixed Point Code ==============
%    
%    ### Generating Fixed Point MATLAB Code <a href="matlab:edit('codegen/mlhdlc_replacement_exp/fixpt/mlhdlc_replacement_exp_fixpt.m')">mlhdlc_replacement_exp_fixpt</a> using Proposed Types
%    ### Generating Fixed Point MATLAB Design Wrapper <a href="matlab:edit('codegen/mlhdlc_replacement_exp/fixpt/mlhdlc_replacement_exp_wrapper_fixpt.m')">mlhdlc_replacement_exp_wrapper_fixpt</a>
%    ### Generating Mex file for ' mlhdlc_replacement_exp_wrapper_fixpt '
%    Code generation successful: To view the report, open('codegen/mlhdlc_replacement_exp/fixpt/fxptmp/mlhdlc_replacement_exp_wrapper_fixpt/html/index.html').
%    ### Generating Type Proposal Report for 'mlhdlc_replacement_exp' <a href="matlab:web('codegen/mlhdlc_replacement_exp/fixpt/mlhdlc_replacement_exp_report.html', '-new')">mlhdlc_replacement_exp_report.html</a>
%    
%    ============= Step4: Verify Fixed Point Code ==============
%    
%    ### Begin Fixed Point Simulation : mlhdlc_replacement_exp_tb
%    ### Fixed Point Simulation Completed in   1.9497 sec(s)
%    ### Generating Type Proposal Report for 'mlhdlc_replacement_exp_fixpt' <a href="matlab:web('codegen/mlhdlc_replacement_exp/fixpt/mlhdlc_replacement_exp_fixpt_report.html', '-new')">mlhdlc_replacement_exp_fixpt_report.html</a>
%    ### Elapsed Time:             2.6488 sec(s)
%    
%    As this is a small design with only one replacement functions you can
%    try different number of points in approximation function generation.
%    Re-examine the generated HDL code and compare it with the previous step.
%    
%    ### Begin VHDL Code Generation
%    ### Generating HDL Conformance Report <a href="matlab:web('codegen/mlhdlc_replacement_exp/hdlsrc/mlhdlc_replacement_exp_fixpt_hdl_conformance_report.html')">mlhdlc_replacement_exp_fixpt_hdl_conformance_report.html</a>.
%    ### HDL Conformance check complete with 0 errors, 2 warnings, and 0 messages.
%    ### Working on mlhdlc_replacement_exp_fixpt as <a href="matlab:edit('codegen/mlhdlc_replacement_exp/hdlsrc/mlhdlc_replacement_exp_fixpt.vhd')">mlhdlc_replacement_exp_fixpt.vhd</a>.
%    ### Generating package file <a href="matlab:edit('codegen/mlhdlc_replacement_exp/hdlsrc/mlhdlc_replacement_exp_fixpt_pkg.vhd')">mlhdlc_replacement_exp_fixpt_pkg.vhd</a>.
%    ### The DUT requires an initial pipeline setup latency. Each output port experiences these additional delays.
%    ### Output port 0: 12 cycles.
%    ### Output port 1: 12 cycles.
%     
%    ### Generating Resource Utilization Report '<a href="matlab:web('codegen/mlhdlc_replacement_exp/hdlsrc/resource_report.html')">resource_report.html</a>'
%    
%    ### Begin TestBench generation.
%    ### Accounting for output port latency: 12 cycles.'
%    ### Collecting data...
%    ### Begin HDL test bench file generation with logged samples
%    ### Generating test bench: codegen/mlhdlc_replacement_exp/hdlsrc/mlhdlc_replacement_exp_fixpt_tb.vhd
%    ### Creating stimulus vectors ...
%     
%    ### Simulating the design 'mlhdlc_replacement_exp_fixpt' using 'ModelSim'.
%    ### Generating Compilation Report codegen/mlhdlc_replacement_exp/hdlsrc/mlhdlc_replacement_exp_fixpt_vsim_log_compile.txt
%    ### Generating Simulation Report codegen/mlhdlc_replacement_exp/hdlsrc/mlhdlc_replacement_exp_fixpt_vsim_log_sim.txt
%    ### Simulation successful.
%     
%    ### Creating Synthesis Project for 'mlhdlc_replacement_exp_fixpt'.
%    ### Synthesis project creation successful.
%     
%     
%    ### Synthesizing the design 'mlhdlc_replacement_exp_fixpt".
%    ### Generating synthesis report codegen/mlhdlc_replacement_exp/hdlsrc/ise_prj/mlhdlc_replacement_exp_fixpt_syn_results.txt.
%    ### Synthesis successful.
% 
% *Examine the Synthesis Results*
% If you have ISE installed on your machine, run the logic synthesis step 
% with the following default options. In the synthesis report, the clock 
% frequency reported by the synthesis tool does not have any optimization options enabled.
% Typically, timing performance of this design by using the Xilinx ISE synthesis tool 
% for the *Virtex7* chip family, device *xc7vh580t*, package *hcg1155*, 
% speed grade -2G, gives a high clock speed in the order of 300 MHz.
% 
%% Clean Up the Generated Files
% To clean up the temporary project folder, run these commands.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_replacement_exp']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
