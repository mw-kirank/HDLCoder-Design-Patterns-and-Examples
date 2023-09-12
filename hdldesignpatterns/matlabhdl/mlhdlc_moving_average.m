function [y, validOut] = mlhdlc_moving_average(x, validIn) %#codegen

% Declare persistent array and persistent window size
persistent array window_size;

% During the first call of the function, variables are initialized.
if isempty(array)
    window_size = fi(25,0,8,0);
    array = fi(zeros(1, 25),0,8,4); % size of the window in this example is 25
end

% The following loop maintains the values needed by moving window.
% This for loop also sums up the values of the array.
sum = fi(0,0,32,15);
if(validIn)    
    for i = 1:24 %had to hard code the window size to avoid unbounded loop error during code generation
        % window_size-fi(1,0,8,4) window size -1 
        sum = fi(sum + array(i+1),0,32,15);
        array(i) = array(i+1);
    end   
    % The last position is updated based on the most recent input.
    array(window_size) = x;
    sum = fi(sum + array(window_size),0,32,15);    
end
y = fi(sum / window_size,0,8,4); % Divided by window size 
validOut = validIn;

end
