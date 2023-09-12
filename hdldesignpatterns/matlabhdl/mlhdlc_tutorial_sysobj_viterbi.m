%% HDL Code Generation from Viterbi Decoder System Object
% This example shows how to check, generate and verify HDL code from
% MATLAB(R) code that instantiates a Viterbi Decoder System object.

%   Copyright 2011-2023 The MathWorks, Inc.

%% MATLAB Design
% The MATLAB code used in this example is a Viterbi Decoder used in hard
% decision convolutional decoding, implemented as a System object.
% This example also shows a MATLAB test bench that tests the decoder.

design_name = 'mlhdlc_sysobj_viterbi';
testbench_name = 'mlhdlc_sysobj_viterbi_tb';

%%
% Let us take a look at the MATLAB design.
type(design_name);

%%
type(testbench_name);


%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_so_viterbi']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);


%% Simulate the Design
% Simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_sysobj_viterbi_tb


%% Hardware Implementation of Viterbi Decoding Algorithm
% There are three main components in the Viterbi decoding algorithm. They
% are the branch metric computation (BMC), add-compare-select (ACS), and traceback decoding. 
% The following diagram illustrates the three units in the Viterbi decoding
% algorithm.
% 
% <<mlhdlc_commviterbihdl_alg.JPG>> 

%% The Renormalization Method 
% The Viterbi decoder prevents the overflow of the state metrics in the ACS component by
% subtracting the minimum value of the state metrics at each time step, as shown in the 
% following figure.
%
% <<mlhdlc_commviterbihdl_normACS.JPG>> 

%%
%
% Obtaining the minimum value of all the state metric elements in one clock cycle results in 
% a poor clock frequency for the circuit. The performance of the circuit may be improved by 
% adding pipeline registers. However, simply subtracting the minimum value delayed by pipeline 
% registers from the state metrics may still lead to overflow. 
%
% The hardware architecture modifies
% the renormalization method and avoids the state metric overflow in three steps. First, the 
% architecture calculates values for the threshold and step parameters, based on the trellis 
% structure and the number of soft decision bits. Second, the delayed minimum value is compared 
% to the threshold. Last, if the minimum value is greater than or equal to the threshold value,
% the implementation subtracts the step value from the state metric; otherwise no adjustment is performed. 
% The following figure illustrates the modified renormalization method.
%
% <<mlhdlc_commviterbihdl_renormmethod.JPG>> 

%% Create a New HDL Coder Project
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new mlhdlc_viterbi
%
% Next, add the file 'mlhdlc_sysobj_viterbi.m' to the project as the MATLAB
% function and 'mlhdlc_sysobj_viterbi_tb.m' as the MATLAB test bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.

%% Run Fixed-Point Conversion and HDL Code Generation
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
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_so_viterbi']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
