%% Generate HDL-Compatible Lookup Table Function Replacements Using 'coder.approximate' 
% This example shows MATLAB(R) code generation from a floating-point MATLAB design 
% that is not ready for code generation. We use 'coder.approximate' function to generate
% a lookup table based MATLAB function. This newly generated function is
% ready for HDL code generation (not shown in this demo).

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
% The MATLAB code used in the example is sigmoid function, which is used
% for threshold detection and decision making problems. For example neural
% networks use sigmoid functions with appropriate thresholds to 'train'
% systems for learning patterns.

%% MATLAB Design
% 
design_name = 'mlhdlc_approximate_sigmoid';
testbench_name = 'mlhdlc_approximate_sigmoid_tb';

%%
% Examine the MATLAB design.
dbtype(design_name)

%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_approximate_sigmoid_tb

%%
%
% # MATLAB Design: <matlab:edit('mlhdlc_approximate_sigmoid') mlhdlc_approximate_sigmoid>
% # MATLAB testbench: <matlab:edit('mlhdlc_approximate_sigmoid_tb') mlhdlc_approximate_sigmoid_tb>
%

%% 
% We can use coder.approximate to generate a lookup-table based replacement function for
% 'mlhdlc_approximate_sigmoid' 

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_fixpt_approximate']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'_design.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Generate fixed-point lookup-table replacements
% 
%   repCfg = coder.approximation('Function','mlhdlc_approximate_sigmoid','CandidateFunction',@mlhdlc_approximate_sigmoid,...
%                             'NumberOfPoints',50,'InputRange',[-10,10],'FunctionNamePrefix','repsig_');
%   coder.approximate(repCfg);
% 
% First the fixed-point conversion completes with appropriate function
% replacements, and following console message,
% 
%  ### Generating approximation for 'sigmoid' : repsiglookuptable.m
%  ### Generating testbench for 'sigmoid' : repsiglookuptable_tb.m
%  ### LookupTable replacement for function 'sigmoid' used 50 data points
% 
% This should generate the MATLAB files 'repsig_lookuptable_tb', and
% 'repsig_lookuptable' containing the testbench and design respectively.

%% Test the replacement functions
% 
% To visually see the degree of match between lookup-table based
% replacement function and the original function use the testbench,
% 
%   repsig_lookuptable_tb();
% 

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fixpt_approximate']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
