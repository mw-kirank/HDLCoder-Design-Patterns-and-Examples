%% High Dynamic Range Imaging
% This example shows how to generate HDL code from a MATLAB(R) design 
% that implements a high dynamic range imaging algorithm.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Algorithm
%  
% High Dynamic Range Imaging (HDRI or HDR) is a set of methods used in
% imaging and photography to allow a greater dynamic range between the
% lightest and darkest areas of an image than current standard digital
% imaging methods or photographic methods. HDR images can represent more
% accurately the range of intensity levels found in real scenes, from
% direct sunlight to faint starlight, and is often captured by way of a
% plurality of differently exposed pictures of the same subject
% matter.
%

%% MATLAB Design
design_name = 'mlhdlc_hdr';
testbench_name = 'mlhdlc_hdr_tb';

%%
% Let us take a look at the MATLAB design
dbtype(design_name);

%%
dbtype(testbench_name);


%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_hdr_tb


%% Setup for the Example
% Executing the following lines copies the necessary files into a temporary folder
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_hdr']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

% copy files to the temp dir
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_hdr_long.png'), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_hdr_short.png'), mlhdlc_temp_dir);


%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_hdr_prj
%
% Next, add the file 'mlhdlc_hdr.m' to the project as the MATLAB
% Function and 'mlhdlc_hdr_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Creating constant parameter inputs
%
% This example shows to use pass constant parameter inputs. 
%
% In this design the input parameters 'plot_y_short_in' and
% 'plot_y_long_in' are constant input parameters. You can define them
% accordingly by modifying the input types as 'constant(double(1x256))'
%
% 'plot_y_short_in' and 'plot_y_short_in' are LUT inputs. They are constant
% folded as double inputs to the design. You will not see port declarations
% for these two input parameters in the generated HDL code.
%
% Note that inside the design 'mlhdlc_hdr.m' these variables are reassigned
% so that they get properly fixed-point converted. This is not necessary if
% these are purely used as constants for defining sizes of variables for
% example and not part of the logic.

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch HDL Advisor and right click on the 'Code Generation' step and choose the option
% 'Run to selected task' to run all the steps from the beginning through the HDL
% code generation. 


%%  Convert the design to fixed-point and generate HDL code
% The following script converts the design to fixed-point, and generate HDL
% code with a test bench.
%    
%    exArgs = {0,0,0,0,0,0,coder.Constant(ones(1,256)),coder.Constant(ones(1,256)),0,0,0};
%    fc = coder.config('fixpt');
%    fc.TestBenchName = 'mlhdlc_hdr_tb';
%    hc = coder.config('hdl');
%    hc.GenerateHDLTestBench = true;
%    hc.SimulationIterationLimit = 1000; % Limit number of testbench points
%    codegen -float2fixed fc -config hc -args exArgs mlhdlc_hdr
% 
% 
% Examine the generated HDL code by clicking on the hyperlinks in the 
% Code Generation Log window.

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_hdr']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
