% Run MEX based Simulation
tic
I = imread('lena_gray256_noise.TIF');
I = im2gray(I);
codegen medianFilter3 -args {I} -o medianFilter3
J = medianFilter3(I);
imshow(I);figure;imshow(J);
toc