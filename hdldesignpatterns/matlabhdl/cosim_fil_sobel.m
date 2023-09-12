%% Verify Sobel Edge Detection Algorithm in MATLAB-to-HDL Workflow
% This example shows how to generate HDL code from a MATLAB design
% implementing the Sobel edge detection algorithm.
%

% Copyright 2012-2023 The MathWorks, Inc.

%% Set Up Example
%
% Run the following code to set up the design:
%
design_name = 'mlhdlc_sobel.m';
testbench_name = 'mlhdlc_sobel_tb.m';

mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sobel'];

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

% copy the design files to the temporary directory
copyfile(fullfile(mlhdlc_demo_dir, design_name), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, testbench_name), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_img_stop_sign.gif'), mlhdlc_temp_dir);

%% Simulate the Design
% It is a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
%

mlhdlc_sobel_tb;


%% Create a New HDL Coder Project
%
% Run the following command to create the HDL code generation project.
%
% coder -hdlcoder -new cosim_fil_sobel

%% Specify the Design and the Test Bench
%
% # Drag the file "mlhdlc_sobel.m" from the Current Folder Browser
% into the Entry Points tab of the HDL Coder UI, under the "MATLAB
% Function" section.
% # Under the newly added "mlhdlc_sobel_tb.m" file, specify the
% data type of input argument "data_in" as "double (1 x 1)"
% # Drag the file 'mlhdlc_sobel_tb.m' into the HDL Coder UI,
% under "MATLAB Test Bench" section.
%
% <<cosim_fil_sobel_screen1.png>> 
%

%% Generate HDL Code
%
% # Click "Workflow Advisor".
% # Right click on the "Code Generation" step in Workflow Advisor.
% # Choose option "Run to selected task" to run all steps from the
% beginning of the workflow through to HDL code generation.
%

%% Verify Generated HDL Code with Cosimulation
%
% To run this step, you must have one of the HDL simulators supported by
% HDL Verifier. See {Supported EDA Tools}. You may skip this step if you do
% not.
%
% 1. Select the "Generate cosimulation test bench" option.
%
% 2. Select the "Log outputs for comparison plots" option. This option
% generates the plotting of the HDL simulator output, the reference MATLAB
% algorithm output, and the differences between them.
%
% 3. For "Cosimulate for use with:", select your HDL simulator. The HDL
% simulator executable must be on your system path.
%
% 4. To view the waveform in the HDL simulator, select "GUI" mode in the
% "HDL simulator run mode in cosimulation" list.
%
% 5. Select "Simulate generated cosimulation test bench".
%
% 6. Click "Run". 
%
% When the simulation is complete, check the comparison
% plots. There should be no mismatch between the HDL simulator output and
% the reference MATLAB algorithm output.
%
% <<cosim_fil_sobel_screen2.png>> 
%

%% Verify Generated HDL Code with FPGA-in-the-Loop
%
% To run this step, you must have one of the supported FPGA boards (see
% {Supported EDA Tools}). Refer to here for additional setup instructions
% required for FPGA-in-the-Loop.
%
% In the "Verify with FPGA-in-the-Loop" step, perform the following steps:
%
% 1. Select the "Generate FPGA-in-the-Loop test bench" option.
%
% 2. Select the "Log outputs for comparison plots" option. This option
% generates the plotting of the FPGA output, the reference MATLAB algorithm
% output, and the differences between them.
%
% 3. Select your FPGA board from the "Cosimulate for use with:" list. If
% your board is not on the list, select one of the following options: 
%
% * "Get more boards..." to download the FPGA board support package(s) (this
% option starts the Support Package Installer)
% * "Create custom board..." to create the FPGA board definition file for
% your particular FPGA board (this option starts the New FPGA Board
% Manager).
%
% 4. Ethernet connection only: Enter your Ethernet connection information
% in the "Board IP Address" and "Board MAC Address:" fields. Leave the
% "Additional Files" field empty.
%
% 5. Select "Simulate generated FPGA-in-the-Loop test bench".
%
% 6. Click "Run".
%
% When the simulation is complete, check the comparison plots. There should be no mismatch between the FPGA output and the reference MATLAB algorithm output. 
%
% <<cosim_fil_sobel_screen3.png>> 
%

%%
% This ends the Verify Sobel Edge Detection Algorithm in MATLAB-to-HDL Workflow example.

displayEndOfDemoMessage(mfilename)

