%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Pipelined Bisection Square root algorithm
% 
% Introduction:
% 
% Implement SQRT by the bisection algorithm in a pipeline, for unsigned fixed
% point numbers (also why you don't need to run fixed-point conversion for this design).
% The demo illustrates the usage of a pipelined implementation for numerical algorithms.
%
% Key Design pattern covered in this example: 
% (1) State of the bisection algorithm is maintained with persistent variables
% (2) Stages of the bisection algorithm are implemented in a pipeline 
% (3) Code is written in a parameterized fashion, i.e. word-length independent, to work for any size fi-type
% 
% Ref. 1. R. W. Hamming, "Numerical Methods for Scientists and Engineers," 2nd, Ed, pp 67-69. ISBN-13: 978-0486652412.
%      2. Bisection method, http://en.wikipedia.org/wiki/Bisection_method, (accessed 02/18/13).
%      

%   Copyright 2013-2015 The MathWorks, Inc.

%#codegen
function [y,z] = mlhdlc_sqrt( x )
    persistent sqrt_pipe
    persistent in_pipe
   if isempty(sqrt_pipe)
       sqrt_pipe = fi(zeros(1,x.WordLength),numerictype(x));
       in_pipe = fi(zeros(1,x.WordLength),numerictype(x));
   end
   
   % Extract the outputs from pipeline
   y = sqrt_pipe(x.WordLength);
   z = in_pipe(x.WordLength); 
   
   % for analysis purposes you can calculate the error between the fixed-point bisection routine and the floating point result.
   %Q = [double(y).^2, double(z)];
   %[Q, diff(Q)]
   
   % work the pipeline
   for itr = x.WordLength-1:-1:1       
       % move pipeline forward
       in_pipe(itr+1) = in_pipe(itr);
       % guess the bits of the square-root solution from MSB to the LSB of word length
       sqrt_pipe(itr+1) = guess_and_update( sqrt_pipe(itr), in_pipe(itr+1), itr );
   end
   
   %% Prime the pipeline
   % with new input and the guess
   in_pipe(1) = x;
   sqrt_pipe(1) = guess_and_update( fi(0,numerictype(x)), x, 1 );
   
   %% optionally print state of the pipeline
   %disp('************** State of Pipeline **********************')
   %double([in_pipe; sqrt_pipe])
   
   return
end

% Guess the bits of the square-root solution from MSB to the LSB in
% a binary search-fashion.
function update = guess_and_update( prev_guess, x, stage )    
    % Key step of the bisection algorithm is to set the bits
    guess = bitset( prev_guess, x.WordLength - stage + 1);
    % compare if the set bit is a candidate solution to retain or clear it
    if ( guess*guess <= x )        
        update = guess;
    else        
        update = prev_guess;
    end
    return
end
