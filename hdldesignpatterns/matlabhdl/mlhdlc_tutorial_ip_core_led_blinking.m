%% Using IP Core Generation Workflow from MATLAB: LED Blinking
% This example shows how to use MATLAB(R) HDL Workflow Advisor to generate a custom
% HDL IP core which blinks LEDs on FPGA board. The generated IP core can be used on 
% Xilinx(R) Zynq(R) platform, or on any Xilinx FPGA with MicroBlaze processor.

% Copyright 2013-2023 The MathWorks, Inc.

%% Introduction
% You can use MATLAB to design, simulate, and verify your application,
% perform what-if scenarios with algorithms, and optimize parameters. You
% can then prepare your design for hardware and software implementation on
% the Zynq-7000 AP SoC by deciding which system elements will be performed
% by the programmable logic, and which system elements will run on the
% ARM(R) Cortex-A9.
%
% Using the guided workflow shown in this example, you can automatically
% generate VHDL(R) code for the programmable logic using HDL Coder(TM),
% export hardware information from the automatically generated EDK project
% to an SDK project for integration of handwritten C code for the ARM
% processor, and implement the design on the Xilinx Zynq Platform.
%
% This example is a step-by-step guide that helps introduce you to the
% HW/SW co-design workflow. In this workflow, you perform the following
% steps:
%
% # Set up your Zynq hardware and tools.
% # Partition your design for hardware and software implementation.
% # Generate an HDL IP core using MATLAB HDL Workflow Advisor.
% # Integrate the IP core into a Xilinx EDK project and program the Zynq
% hardware.
%
% For more information, refer to other more advanced examples, and the HDL
% Coder documentation.

%% Requirements
%
% # Xilinx ISE 14.4
% # Xilinx Zynq-7000 SoC ZC702 Evaluation Kit running the Linux(R) image in the 
% Base Targeted Reference Design 14.4
% # HDL Coder Support Package for Xilinx Zynq Platform

%% Set up Zynq hardware and tools
% *1.* Set up the Xilinx Zynq ZC702 evaluation kit. Please follow the 
% hardware setup steps in HDL Coder example "Getting Started with HW/SW Co-Design Workflow 
% for Xilinx Zynq Platform".
%
% *2.* Set up the Xilinx ISE synthesis tool path using the following command in the 
% MATLAB command window. Use your own ISE installation path when you run the command.
%
%  hdlsetuptoolpath('ToolName', 'Xilinx ISE', 'ToolPath', 'C:\Xilinx\14.4\ISE_DS\ISE\bin\nt64\ise.exe');

%% Partition your design for hardware and software implementation
% The first step of the Zynq HW/SW co-design workflow is to decide which
% parts of your design to implement on the programmable logic, and which
% parts to run on the ARM processor.
%
% Group the parts of your algorithm that you want to implement on
% programmable logic into a MATLAB function. This function is the boundary
% of your hardware/software partition. All the MATLAB code within this
% function will be implemented on programmable logic. You must provide C
% code that implements the MATLAB code outside this function to run on the
% ARM processor.
%
% In this example, the function *mlhdlc_ip_core_led_blinking* is
% implemented on hardware. It models a counter that blinks the LEDs on an
% FPGA board. Two input ports, *Blink_frequency* and *Blink_direction*, are
% control ports that determine the LED blink frequency and direction. You
% can adjust the input values of the hardware subsystem via prompt options
% in the included embedded software, 'mlhdlc_ip_core_led_blinking_driver.c'
% and 'mlhdlc_ip_core_led_blinking_driver.h'. The embedded software, which
% runs on the ARM processor, controls the generated IP core by writing to
% the AXI interface accessible registers. The output port of the hardware
% subsystem, *LED*, connects to the LED hardware. The output port,
% *Read_Back*, can be used to read data back to the processor.

design_name = 'mlhdlc_ip_core_led_blinking';
testbench_name = 'mlhdlc_ip_core_led_blinking_tb';
sw_driver_name = 'mlhdlc_ip_core_led_blinking_driver.c';
sw_driver_header_name = 'mlhdlc_ip_core_led_blinking_driver.h';

%%
% Let us take a look at the MATLAB design.
type(design_name);

%%
type(testbench_name);

%% Setup for the Example
% The following commands copy the necessary example files into a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_ip_core_led_blinking']; 

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's'); 
mkdir(mlhdlc_temp_dir); 
cd(mlhdlc_temp_dir);

% Copy the design files to the temporary directory
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, sw_driver_name), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, sw_driver_header_name), mlhdlc_temp_dir);

%% Create a New HDL Coder Project
%
%   coder -hdlcoder -new mlhdlc_ip_core_led_blinking_prj
%
% Next, add the file 'mlhdlc_ip_core_led_blinking.m' to the project as the
% MATLAB Function and 'mlhdlc_ip_core_led_blinking_tb.m' as the MATLAB Test
% Bench.
%
% See <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> for a more complete 
% tutorial on creating and populating MATLAB HDL Coder projects.

%% Select Code Generation Target
% Using the IP Core Generation workflow in the HDL Workflow Advisor enables
% you to automatically generate a sharable and reusable IP core module from
% a MATLAB function. The generated IP core is designed to be connected
% to an embedded processor on an FPGA device. HDL Coder generates HDL
% code from the MATLAB design function, and also generates HDL code for
% the AXI interface logic connecting the IP core to the embedded processor.
% HDL Coder packages all the generated files into an IP core folder.
% You can then integrate the generated IP core with a larger FPGA embedded
% design in the Xilinx EDK environment.
%
% To choose the IP core Generation workflow:
%
% *1.* Open the HDL Workflow Advisor and right-click *Select Code
% Generation Target*.
%
% *2.* For *Workflow*, select *IP Core Generation*.
%
% <<mlhdlc_ip_core_led_blinking_select_codegen_target.png>>

%% Platform Selection
% There is a generic option called *Generic Xilinx Platform* in the
% platform selection. This option is board-independent and generates a
% generic Xilinx IP core, which has to be manually integrated into your EDK
% environment.
%
% The remaining options are board-specific and provide the additional
% capability of integrating the generated IP core into a Xilinx PlanAhead
% project, synthesize the project and download the bitstream to FPGA within
% the HDL Workflow Advisor.
%
% For *Platform*, select *Xilinx Zynq ZC702 evaluation kit*. If you don't
% have this option, select *Get more* to open the Support Package
% Installer. In the Support Package Installer, select Xilinx Zynq Platform and
% follow the instructions provided by the Support Package Installer to
% complete the installation.

%% Convert Design To Fixed-Point
% *1.* Right-click the *Define Input Types* task and select *Run This
% Task*.
% 
% *2.* In the *Fixed-Point Conversion* task, click *Advanced* and set the
% *Safety margin for sim min/max (%)* to 0.
%
% *3.* Set the proposed type of the *freqCounter* variable to unsigned
% 24-bit integer by entering *numerictype(0, 24, 0)* in its 'Proposed Type'
% column.
%
% <<mlhdlc_ip_core_led_blinking_fixed_point_conv.png>>
%
% *4.* On the left, right-click the *Fixed-Point Conversion* task and
% select *Run This Task*.

%% Configure the Target Interface
% Map each port in your MATLAB design function to one of the IP core target
% interfaces in the *Set Target Interface* subtask.
%
% In this example, input ports *Blink_frequency* and *Blink_direction* are
% mapped to the AXI4-Lite interface, so HDL Coder(TM) generates AXI
% interface accessible registers for them. The *LED* output port is mapped
% to an external interface, *LEDs General Purpose [0:7]*, which connects to
% the LED hardware on the Zynq board.
%
% <<mlhdlc_ip_core_led_blinking_set_target_interface.png>>

%% Generate IP Core
% Right-click the *HDL Code Generation* step and select *Run this task* to
% generate the IP Core along with the IP Core Report.

%% Integrate the IP core with the Xilinx EDK environment
% In this part of the workflow, you insert your generated IP core into a
% embedded system reference design, generate an FPGA bitstream, and
% download the bitstream to the Zynq hardware.
%
% The reference design is a predefined Xilinx EDK project. It contains all
% the elements the Xilinx software needs to deploy your design to the Zynq
% platform, except for the custom IP core and embedded software.
%
% *1.* To integrate with the Xilinx EDK environment, right-click the
% *Create Project* step under 'Embedded System Integration', and choose the
% option 'Run This Task'. A Xilinx PlanAhead project with EDK embedded
% design is generated, and a link to the project is provided in the dialog
% window. You can optionally open up the project to take a look.
%
% <<mlhdlc_ip_core_led_blinking_create_edk_project.png>>
%
% *2.* Build the FPGA bitstream in the *Build Embedded System* step. Make
% sure the 'Run build process externally' option is checked, so the Xilinx
% synthesis tool will run in a separate process from MATLAB. Wait for the
% synthesis tool process to finish running in the external command window.
%
% <<mlhdlc_ip_core_led_blinking_build_bitstream.png>>
%
% *3.* After the bitstream is generated, right-click the 'Program Target
% Device' step and choose the option *Run This Task* to program the Zynq
% hardware.
%
% <<mlhdlc_ip_core_led_blinking_program.png>>
%
% After you program the FPGA hardware, the LED starts blinking on your Zynq
% board.
%
% Next, you will integrate the included handwritten C code to run on the
% ARM processor to control the LED blink frequency and direction.

%% Run the software on Zynq ZC702 hardware
% The included C code files, *'mlhdlc_ip_core_led_blinking_driver.c'* and
% *'mlhdlc_ip_core_led_blinking_driver.h'*, implement a simple menu that
% enables you to set the LED blink frequency and direction. You can use
% them for your Linux-based SDK project.
%
% <<mlhdlc_ip_core_led_blinking_software.png>>
%
% For instructions on how to integrate the included C code into an SDK
% project and run it on Zynq ZC702 hardware, please refer to the Xilinx
% documentation.


%% Clean up the Generated Files
% Run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_ip_core_led_blinking']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)


