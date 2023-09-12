%% Transmit and Receive FIFO
% This example shows how to generate HDL code from MATLAB(R) code modeling
% transfer data between transmit and receive FIFO.

%   Copyright 2011-2023 The MathWorks, Inc.

%%
% Let us take a look at the MATLAB design for the transmit and receive FIFO
% and a testbench that exercises both designs.
design_core1 = 'mlhdlc_rx_fifo';
design_core2 = 'mlhdlc_tx_fifo';
testbench_name = 'mlhdlc_fifo_tb';

%%
type('mlhdlc_rx_fifo');

%%
type('mlhdlc_tx_fifo');

%%
type('mlhdlc_fifo_tb');

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_fifo']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_fifo_tb.m*'), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_rx_fifo.m*'), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_tx_fifo.m*'), mlhdlc_temp_dir);

% Additional test files
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_rx_fifo_tb.m*'), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_tx_fifo_tb.m*'), mlhdlc_temp_dir);

%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_fifo_tb

%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_fifo
%
% Next, add the file 'mlhdlc_fifo.m' to the project as the MATLAB
% Function and 'mlhdlc_fifo_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch the Workflow Advisor from the Build tab and right click on the 
% 'Code Generation' step and choose the option 'Run to selected task' to 
% run all the steps from the beginning through the HDL code generation. 
%
% Examine the generated HDL code by clicking on the hyperlinks in the 
% Code Generation Log window.

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_fifo']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
