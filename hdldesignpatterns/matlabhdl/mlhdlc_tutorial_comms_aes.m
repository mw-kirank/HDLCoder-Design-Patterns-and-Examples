%% Advanced Encryption System (AES)
% This example shows how to generate HDL code from MATLAB(R) design implementing
% an Advanced Encryption and Decryption Algorithm (AES-128)

%   Copyright 2011-2023 The MathWorks, Inc.

%% MATLAB Design
% 

% AES Encryption Design
design_name_encryption = 'mlhdlc_aes';
% AES Decryption Design
design_name_decryption = 'mlhdlc_aesd';

% Common Test Bench for both AES designs
testbench_name = 'mlhdlc_aes_tb';

%%
% Lets look at the AES Encryption Design
type(design_name_encryption);

%%
% Lets look at the AES Decryption Design
type(design_name_decryption);

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_aes']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

% copy files to the temp dir
copyfile(fullfile(mlhdlc_demo_dir, [design_name_encryption,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [design_name_decryption,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_aes_tb

%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_aes_prj
%
% Next, add the file 'mlhdlc_aes.m' to the project as the MATLAB
% Function and 'mlhdlc_aes_tb.m' as the MATLAB Test Bench.
%
% You can refer to <mlhdlc_tutorial_sfir.html Getting Started with MATLAB to HDL Workflow> tutorial
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects.

%% Run HDL Code Generation
%
% This design is already in fixed point and suitable for HDL code
% generation. It is not desirable to run floating point to fixed point
% advisor on this design.
%
% # Launch Workflow Advisor 
% # Choose 'No' for the option 'Design needs conversion to fixed-point'
% # Click on the 'Code Generation' step and click 'Run'
%
% Examine the generated HDL code by clicking on the hyperlinks in the 
% Code Generation Log window.

%% Repeat the Code Generation steps for the Decryption Design
% Please choose and specify MATLAB Function 'mlhdlc_aesd' instead of the
% encryption design 'mlhdlc_aesd' and repeat the same steps using the 
% MATLAB Test Bench 'mlhdlc_aes_tb' in the project. 
%
%   coder -hdlcoder -new mlhdlc_aes_decryption
%

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_aes']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');



displayEndOfDemoMessage(mfilename)
