% Nonrestoring Squareroot Testbench

%   Copyright 2014-2015 The MathWorks, Inc.

% Generate some random data
rng('default'); % set the random number generator to a consistent state
nsamp = 100; %number of samples
nbits = 32; % fixed-point word length
nfrac = 31; % fixed-point fraction length

data_i = fi(rand(1,nsamp), numerictype(0,nbits,nfrac));

% clear any persistent variables in the HDL function
clear mlhdlc_sysobj_nonrestsqrt

% Determine the "golden" sqrt results
data_go = sqrt(data_i);

% Commands for the sqrt engine
LOAD_DATA = true;
CALC_DATA = false;

% Pre-allocate the result array
data_o = zeros(1,nsamp, 'like', data_go);
% Load in a sample, then iterate until the results are ready
cyc_cnt = 0; 
for i = 1:nsamp
    % Load the new sample into the sqrt engine
    [~, vld] = mlhdlc_sysobj_nonrestsqrt(data_i(i),LOAD_DATA);
    cyc_cnt = cyc_cnt + 1;
    while(vld == false)
        % Iterate until the result has been found
        [data_o(i), vld] = mlhdlc_sysobj_nonrestsqrt(data_i(i),CALC_DATA);
        cyc_cnt = cyc_cnt + 1;
    end
end

% find the integer representation of the result data
idt = numerictype(0,ceil(nbits/2),0);
% find the error in terms of integer bits
ierr = abs(double(reinterpretcast(data_o,idt))-double(reinterpretcast(data_go,idt)));
% find the error in terms of real-world values
derr = abs(double(data_o)- double(data_go));
pct_err = 100*derr ./ double(data_go);

fprintf('Maximum Error: %d (%0.3f %%)\n', max(derr), max(pct_err));
fprintf('Maximum Error (as unsigned integer): %d\n', max(ierr));
fprintf('Number of cycles: %d ( %d per sample)\n', cyc_cnt, cyc_cnt / nsamp);

%EOF