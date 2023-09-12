%% Getting Started with FPGA Turnkey Workflow
% This example shows how to program a standalone FPGA with your MATLAB
% design, using the FPGA Turnkey workflow.
%
% The target device in this example is a Xilinx &reg; Virtex-5 ML506 development
% board.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Introduction
% In this example, the function *'mlhdlc_ip_core_led_blinking'* models a
% counter that blinks the LEDs on an FPGA board.
%
% Two input ports, *Blink_frequency* and *Blink_direction*, are control
% ports that determine the LED blink frequency and direction.
%
% You can adjust the input values of the hardware via push-buttons on
% Xilinx &reg; Virtex-5 ML506 development board. The output port of the design
% function, 'LED', connects to the LED hardware.

design_name = 'mlhdlc_turnkey_led_blinking';
testbench_name = 'mlhdlc_turnkey_led_blinking_tb';

%%
% Let us take a look at the MATLAB design
type(design_name);

%%
type(testbench_name);

%% Create a New Folder and Copy Relevant Files
% Execute the following lines of code to copy the necessary example files
% into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_turnkey_led_blinking']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_turnkey_led_blinking_prj
%
% Next, add the file 'mlhdlc_turnkey_led_blinking.m' to the project as the
% MATLAB Function and 'mlhdlc_turnkey_led_blinking_tb.m' as the MATLAB Test
% Bench.
%
% See <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> for a more complete
% tutorial on creating and populating MATLAB HDL Coder projects.

%% Convert Design To Fixed-Point
% *1.* Right-click the *Define Input Types* task and select *Run This
% Task*.
% 
% *2.* In the Fixed-Point Conversion task, click *Advanced* and set the
% *Safety margin for sim min/max (%)* to 0.
%
% *3.* Set the proposed type of the *freqCounter* variable to unsigned
% 27-bit integer by entering *numerictype(0, 27, 0)* in its 'Proposed Type'
% column.
%
% <<mlhdlc_turnkey_xilinx_fixed_point_conv.png>>
%
% *4.* On the left, right-click the *Fixed-Point Conversion* task and
% select *Run This Task*.

%% Map Design Ports to Target Interface
% In the *Select Code Generation Target* task, select the *FPGA Turnkey*
% workflow and *Xilinx Virtex-5 ML506 development board* as follows:
%
% *1.* For *Workflow*, select *FPGA Turnkey*.
%
% *2.* For *Platform*, select *Xilinx Virtex-5 ML506 development board*. If
% your target device is not in the list, select *Get more* to download the
% support package. The coder automatically sets *Chip family*, *Device*,
% *Package*, and *Speed* according to your platform selection.
%
% *3.* For FPGA clock frequency, for both *Input* and *System*, enter 100.
%
% <<mlhdlc_turnkey_xilinx_select_codegen_target.png>>
%
% *4.* In the *Set Target Interface* task, map the design input and output
% ports to interfaces on the target device by setting the fields in the
% *Target Platform Interfaces* column as follows:
%
% # Blink_frequency_1 to *User Push Buttons N-E-S-W-C [0:4]*
%
% # Blink_direction to User Push Buttons *N-E-S-W-C [0:4]*
%
% # LED to *LEDs General Purpose [0:7]*
%
% You can leave the 'Read_back' port unmapped.
%
% <<mlhdlc_turnkey_xilinx_set_target_interface.png>>

%% Generate Programming File and Download To Hardware
% You can generate code, perform synthesis and analysis, and download the
% design to the target hardware using the default settings:
%
% *1.* For the *Synthesis and Analysis* task group, uncheck the *Skip this
% Step* option.
%
% *2.* For the *Download to Target* task group, uncheck the *Skip this
% Step* option.
%
% *3.* Right-click *Download to Target > Generate Programming File* and
% select *Run to Selected Task*.
%
% *4.* If your target hardware is connected and ready to program, select
% the *Program Target Device* subtask and click *Run*.

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_turnkey_led_blinking']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
