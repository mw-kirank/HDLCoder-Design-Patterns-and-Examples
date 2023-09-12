%% Image Enhancement by Histogram Equalization
% This example shows how to generate HDL code from a MATLAB(R) design 
% that does image enhancement using histogram equalization.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Algorithm
%  
% The Histogram Equalization algorithm enhances the contrast of images by 
% transforming the values in an intensity image so that the histogram 
% of the output image is approximately flat.
%
%   I = imread('pout.tif');
%   J = histeq(I);
%   subplot(2,2,1);
%   imshow( I );
%   subplot(2,2,2);   
%   imhist(I)
%   subplot(2,2,3);
%   imshow( J );
%   subplot(2,2,4);
%   imhist(J)
%
% <<mlhdlc_histeq_io.png>>

%% MATLAB Design
design_name = 'mlhdlc_heq';
testbench_name = 'mlhdlc_heq_tb';

%%
% Let us take a look at the MATLAB design
type(design_name);

%%
type(testbench_name);


%% Simulate the Design
% It is always a good practice to simulate the design with the testbench prior to
% code generation to make sure there are no runtime errors.
mlhdlc_heq_tb


%% Setup for the Example
% Executing the following lines copies the necessary files into a temporary folder
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_heq']; 

% create a temporary folder and copy the MATLAB files
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

% copy files to the temp dir
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_img_peppers.png'), mlhdlc_temp_dir);


%% Create a New HDL Coder(TM) Project
%
%   coder -hdlcoder -new mlhdlc_heq_prj
%
% Next, add the file 'mlhdlc_heq.m' to the project as the MATLAB
% Function and 'mlhdlc_heq_tb.m' as the MATLAB Test Bench.
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run Fixed-Point Conversion and HDL Code Generation
% Launch HDL Advisor and right click on the 'Code Generation' step and choose the option
% 'Run to selected task' to run all the steps from the beginning through the HDL
% code generation. 
%
% Examine the generated HDL code by clicking on the hyperlinks in the 
% Code Generation Log window.

%% Clean up the Generated Files
% You can run the following commands to clean up the temporary project folder.
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_heq']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
