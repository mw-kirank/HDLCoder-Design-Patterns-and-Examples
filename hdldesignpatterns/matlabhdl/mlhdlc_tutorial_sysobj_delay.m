%% Model State with Persistent Variables and System Objects
% This example shows how to use persistent variables and System objects to
% model state and delays in a MATLAB(R) design for HDL code generation.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
% Using System objects to model delay results in concise generated code.
%
% In MATLAB, multiple calls to a function having persistent
% variables do not result in multiple delays. Instead, the state in the
% function gets updated multiple times.

% In order to reuse code implemented in a function with states, 
% you need to duplicate functions multiple times to create multiple 
% instances of the algorithm with delay.

%% Examine the MATLAB Code
% Let us take a quick look at the implementation of the Sobel algorithm.
% 
% Examine the design to see how the delays and line buffers are modeled using:
%
% * Persistent variables: <matlab:edit('mlhdlc_sobel') mlhdlc_sobel>
% * System objects: <matlab:edit('mlhdlc_sysobj_sobel') mlhdlc_sysobj_sobel>
%
% Notice that the 'filterdelay' function is duplicated with different
% function names in 'mlhdlc_sobel' code to instantiate multiple versions of the
% algorithm in MATLAB for HDL code generation.
%
% The delay line implementation is more complicated when done
% using MATLAB persistent variables.  
%
% Now examine the simplified implementation of the same algorithm
% using System objects in 'mlhdlc_sysobj_sobel'.
%
% When used within the constraints of HDL code
% generation, the dsp.Delay objects always map to registers. 
% For persistent variables to be inferred as registers, you have 
% to be careful to read the variable before writing to it to map it to 
% a register.
%

%% MATLAB Design

demo_files = {...
    'mlhdlc_sysobj_sobel', ...
    'mlhdlc_sysobj_sobel_tb', ...
    'mlhdlc_sobel', ...
    'mlhdlc_sobel_tb'
    };

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_delay_modeling']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

for ii=1:numel(demo_files)
    copyfile(fullfile(mlhdlc_demo_dir, [demo_files{ii},'.m*']), mlhdlc_temp_dir);
end

%% Known Limitations
% 
% For predefined System Objects, HDL Coder(TM) only supports the 'step' method 
% and does not support 'output' and 'update' methods.
%
% With support for only the step method, delays cannot be used 
% in modeling feedback paths. For example, the following piece of MATLAB 
% code cannot be supported using the dsp.Delay System object.
%
%   %#codegen
%   function y = accumulate(u)
%   persistent p;
%   if isempty(p)
%      p = 0;
%   end
%   y = p;
%   p = p + u;
%

%% Create a New HDL Coder Project
% To create a new project, enter the following command:
%
%   coder -hdlcoder -new mlhdlc_sobel
%
% Next, add the file 'mlhdlc_sobel.m' to the project as the MATLAB
% Function and 'mlhdlc_sobel_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.  

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch the Workflow Advisor and right-click the 
% 'Code Generation' step. Choose the option 'Run to selected task' to 
% run all the steps from the beginning through HDL code generation. 
%
% Examine the generated HDL code by clicking the hyperlinks in the 
% Code Generation Log window.
%
% Now, create a new project for the system object design:
%
%   coder -hdlcoder -new mlhdlc_sysobj_sobel
%
% Add the file 'mlhdlc_sysobj_sobel.m' to the project as the MATLAB
% Function and 'mlhdlc_sysobj_sobel_tb.m' as the MATLAB Test Bench.
%
% Repeat the code generation steps and examine the generated fixed-point
% MATLAB and HDL code.

%% Additional Notes:
% You can model integer delay using dsp.Delay object by setting the
% 'Length' property to be greater than 1. These delay objects will be mapped to shift
% registers in the generated code. 
%
% If the optimization option 'Map
% persistent array variables to RAMs' is enabled, delay System objects will
% get mapped to block RAMs under the following conditions:
%
% * 'InitialConditions' property of the dsp.Delay is set to zero.
% * Delay input data type is not floating-point.
% * RAMSize (DelayLength * InputWordLength) is greater than or equal to the 'RAM Mapping
% Threshold'.

%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_delay_modeling']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
