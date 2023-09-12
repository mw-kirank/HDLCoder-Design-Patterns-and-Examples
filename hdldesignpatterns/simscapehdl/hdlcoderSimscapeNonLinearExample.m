%% Simscape to Simulink Conversion: Field-Oriented Control Algorithm
% In this example, you will review a non-linear Simscape model and it's 
% manually converted HDL-friendly Simulink model.

% Copyright 2017-2020 The MathWorks, Inc.

%% Introduction
%
% You have seen the <hdlcoderFocCurrentFloatScript.html FOC Model> that takes
% a deep dive into how to generate HDL code for current control algorithm. 
%
% In this example, however, we will dive into the plant and show you
% how to generate HDL code for plant as well. In the final stretch, you can
% generate HDL code for both plant and controller.
%
% The demo starts with same testbench model 'hdlcoderFocCurrentTestBench'.
% 

%% Verify Behavior through Simulation.
hasSimPowerSystems = license ('test', 'Power_System_Blocks');
if hasSimPowerSystems
   open_system('hdlcoderFocCurrentTestBench')
   
   % set single-precision floating-point model in the testbench
   set_param('hdlcoderFocCurrentTestBench/Controller', 'ModelName', 'hdlcoderFocCurrentFloatHdl');
   
   set_param('hdlcoderFocCurrentTestBench','IgnoredZcDiagnostic','none');
   sim('hdlcoderFocCurrentTestBench')
   set_param('hdlcoderFocCurrentTestBench','IgnoredZcDiagnostic','warn');
end

%% Examine the Plant model
% Please see the plant model below:
% <<hdlcoder_foc_plant_model.png>>
%%
% The plant contains non-linear motor (PMSM) connected to an inverter
% electrical systems.
% <<hdlcoder_foc_pmsm.png>>
%%
% <<hdlcoder_foc_inverter.png>>


%% Manual Conversion of the plant
% HDLCoder provides the following script that enables user to convert any 
% linear or switched-linear Simscape models to Simulink using a solver.
% <ssccodegenadvisior>
%
% However, the plant model is non-linear and thus it requires manual effort
% to convert the model to equivalent Simulink representation. Please see
% below for the equivalent Simulink representation of the plant.
open_system('hdlcoderFocControllerAndPMSM')
sim('hdlcoderFocControllerAndPMSM')

%% Generate HDL Code for complete FoC model
% You can generate and review HDL code for subsystem containing both plant 
% and controller.
makehdl('hdlcoderFocControllerAndPMSM/Controller_and_Plant');

