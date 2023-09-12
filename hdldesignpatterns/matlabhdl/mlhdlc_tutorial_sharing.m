%% Resource Sharing of Multipliers to Reduce Area
%
% This example shows how to use the resource sharing optimization in 
% HDL Coder(TM). This optimization identifies functionally equivalent
% multiplier operations in MATLAB(R) code and shares them in order to
% optimize design area. You have control over the number of multipliers to
% be shared in the design.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
%
% Resource sharing is a design-wide optimization supported by HDL Coder(TM) for 
% implementing area-efficient hardware. 
%
% This optimization enables users to share hardware 
% resources by mapping 'N' functionally-equivalent 
% MATLAB operators, in this case multipliers, to a single operator. 
%
% The user specifies 'N' using the 'Resource Sharing Factor' option 
% in the optimization panel.
%
% Consider the following example model of a symmetric FIR filter. 
% It contains 4 product blocks that are functionally equivalent and 
% which are mapped to 4 multipliers in hardware. The Resource Utilization 
% Report shows the number of multipliers inferred from the design. 
% 
% In this example you will run fixed-point conversion on the MATLAB design
% 'mlhdlc_sharing' followed by HDL Coder. This prerequisite step
% normalizes all the multipliers used in the fixed-point code.
% You will input a 'proposed-type settings' during this fixed-point
% conversion phase.

%% MATLAB Design
% The MATLAB code used in the example is a simple symmetric FIR filter written
% in MATLAB and also has a testbench that exercises the filter.

design_name = 'mlhdlc_sharing';
testbench_name = 'mlhdlc_sharing_tb';

%%
% Let us take a look at the MATLAB design.
type(design_name);

%%
type(testbench_name);


%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sfir_sharing']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Create a New HDL Coder Project
% Run the following command to create a new project:
%
%   coder -hdlcoder -new mlhdlc_sfir_sharing
%
% Next, add the file 'mlhdlc_sharing.m' to the project as the MATLAB
% Function and 'mlhdlc_sharing_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.

%% Realize an N-to-1 Mapping of Multipliers
%
% Turn on the resource sharing optimization by setting the 'Resource Sharing
% Factor' to a positive integer value.
%
% This parameter specifies 'N' in the N-to-1 hardware mapping. Choose a
% value of N > 1.
%
% <<mlhdlc_sharing_options.png>>

%% Examine the Resource Report
%
% There are 4 multiplication operators in this example design.
% Generating HDL with a 'SharingFactor' of 4 will result in only one multiplier
% in the generated code.
% 
% <<mlhdlc_sharing_report.png>>

%% Sharing Architecture
% The following figure shows how the algorithm is implemented in
% hardware when we synthesize the generated code without turning on the 
% sharing optimization.
%
% <<mlhdlc_sfir_unshared.png>>
%
% The following figure shows the sharing architecture automatically
% implemented by HDL Coder when the sharing optimization option is turned on.
%
% The inputs to the shared multiplier are time-multiplexed
% at a faster rate (in this case 4x faster and denoted in red). 
% The outputs are then routed to the respective consumers 
% at a slower rate (in green).
%
% <<mlhdlc_sfir_shared.png>>

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch the Workflow Advisor and right-click the 
% 'Code Generation' step. Choose the option 'Run to selected task' to 
% run all the steps from the beginning through the HDL code generation. 
% 
% The detailed example <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_derived_ranges>
% provides a tutorial for updating the type proposal settings during fixed-point conversion.
% 
% Note that to share multipliers of different word-length, in the Optimization -> 
% Resource Sharing tab of HDL Configuration Parameters,  specify the 'Multiplier promotion threshold'. 
% For more information, see the Resource Sharing Documentation.

%% Run Synthesis and Examine Synthesis Results
% Synthesize the generated code from the design with this
% optimization turned off, then with it turned on, and examine the area
% numbers in the resource report.

%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_sfir_sharing']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
