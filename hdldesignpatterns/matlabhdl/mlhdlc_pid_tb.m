
%

%   Copyright 2011-2015 The MathWorks, Inc.

clear mlhdlc_pid
numSteps = 1000;
numChannels = 24;

td = zeros(1, numChannels);

pid_arr = zeros(numSteps, numChannels);
for ii=1:numSteps
    pid_out = mlhdlc_pid(td);
    td = [td(2:numChannels), ii];
    pid_arr(ii, :) = pid_out;
end

figure('Name', [mfilename, '_plot']);

plot((1:1000), pid_arr(1:1000, :));
