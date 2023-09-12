%% HDL Code Generation for Harris Corner Detection Algorithm
% This example shows how to generate HDL code from a MATLAB(R) design that 
% computes the corner metric by using Harris' technique.

%   Copyright 2011-2023 The MathWorks, Inc.

%% Corner Detection Algorithm
% A corner is a point in an image where two edges of the image intersect. The 
% corners are robust to image rotation, translation, and illumination.
% Corners contain important features that you can use in many applications 
% such as restoring image information, image registration, and object tracking.
%
% Corner detection algorithms identify the corners by using a corner metric.
% This metric corresponds to the likelihood of pixels located at the corner of
% certain objects. Peaks of corner metric identify the corners. See also
% <docid:vision_ref#bq9n9a5-1 Corner Detection> in the Computer Vision Toolbox 
% documentation. The corner detection algorithm:
% 
% 1. Reads the input image.
%
%   Image_in = checkerboard(10); 
%%
% 2. Finds the corners.
%
%   cornerDetector = detectHarrisFeatures(Image_in);
%%
% 3. Displays the results.
%
%   [~,metric] = step(cornerDetector,image_in); 
%   figure; 
%   subplot(1,2,1); 
%   imshow(image_in); 
%   title('Original'); 
%   subplot(1,2,2); 
%   imshow(imadjust(metric)); 
%   title('Corner metric'); 

%% Corner Detection MATLAB Design
design_name = 'mlhdlc_corner_detection';
testbench_name = 'mlhdlc_corner_detection_tb';
%%
% Review the MATLAB design:
edit(design_name);
%%
% <include>mlhdlc_corner_detection.m</include>
%
% The MATLAB function is modular and uses several functions to compute the
% corners of the image. The function:
%
% * |compute_corner_metric| computes the corner metric matrix by instantiating
% the function |compute_harris_metric|. 
% * |compute_harris_metric| detects the corner features in the input image by
% instantiating functions |gaussian_filter| and |reduce_matrix|. The
% function takes outputs of |make_buffer_matrix_gh| and |make_buffer_matrix_gv| 
% as the inputs.

%% Corner Detection MATLAB Test Bench
% Review the MATLAB test bench:
edit(testbench_name);
%%
% <include>mlhdlc_corner_detection_tb.m</include>

%%  Test the MATLAB Algorithm
% To avoid run-time errors, simulate the design with the test bench.
mlhdlc_corner_detection_tb

%% Create a Folder and Copy Relevant Files
% Before you generate HDL code for the MATLAB design, copy the
% design and test bench files to a writeable folder. These commands
% copy the files to a temporary folder.
mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
mlhdlc_temp_dir = [tempdir 'mlhdlc_cdetect']; 
%%
% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's'); 
mkdir(mlhdlc_temp_dir); 
cd(mlhdlc_temp_dir);
%%
% Copy the design files to the temporary directory.
copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, 'mlhdlc_sobel.m*'), mlhdlc_temp_dir);

%% Create an HDL Coder(TM) Project
%
% 1. Create a HDL Coder project:
%
%   coder -hdlcoder -new mlhdlc_corner_detect_prj
%
% 2. Add the file |mlhdlc_corner_detection.m| to the project as the *MATLAB
% Function* and |mlhdlc_corner_detection_tb.m| as the *MATLAB Test Bench*.
%
% 3. Click *Autodefine types* to use the recommended types for the inputs
% and outputs of the MATLAB function |mlhdlc_corner_detection.m|.
%
% <<mlhdlc_corner_detection_project.png>>
%
% Refer to <docid:hdlcoder_gs#example-mlhdlc_tutorial_sfir> 
% for a more complete tutorial on creating and populating MATLAB HDL Coder
% projects. 

%% Run Fixed-Point Conversion and HDL Code Generation
%
% # Click the *Workflow Advisor* button to start the Workflow Advisor.
% # Right click the *HDL Code Generation* task and select *Run to selected task*. 
%
% A single HDL file |mlhdlc_corner_detection_fixpt.vhd| is generated for the MATLAB design. 
% To examine the generated HDL code for the filter design, click the hyperlinks 
% in the Code Generation Log window.
%
% If you want to generate a HDL file for each function in your MATLAB design,
% in the *Advanced* tab of the *HDL Code Generation* task, select the 
% *Generate instantiable code for functions* check box. See also
% <docid:hdlcoder_ug#bt3r8wk-1 Generate Instantiable Code for Functions>.

%% Clean Up Generated Files
% To clean up the temporary project folder, run these commands:
%
%   mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
%   mlhdlc_temp_dir = [tempdir 'mlhdlc_cdetect']; 
%   clear mex;
%   cd (mlhdlc_demo_dir);
%   rmdir(mlhdlc_temp_dir, 's');

displayEndOfDemoMessage(mfilename)
