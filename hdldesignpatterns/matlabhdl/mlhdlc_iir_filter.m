function y = mlhdlc_iir_filter(x, sos, g)
%

%   Copyright 2011-2015 The MathWorks, Inc.

% Declare persistent variables and initialize
numSections = numel(sos)/6;
persistent z
if isempty(z)	
	z = zeros(numSections, 2);
end

y = x;
for i=coder.unroll(1:numSections)
    curSOS = sos((i-1)*6+1:i*6);
    [y, z(i,:)] = biquad_filter(y, curSOS(1:3), curSOS(4:6), z(i, :));
end
y = y * g;

end

function [y, z] = biquad_filter (x, b, a, z)
% a(1) is assumed to be 1
% Direct-form II implementation

tmp = x - z(1)*a(2) - z(2)*a(3);
y = z(2) * b(3) + z(1) * b(2) + tmp * b(1);
z(2) = z(1);
z(1) = tmp;

end
