% normcdf variant
function y = mlhdlc_european_call_normcdf( x )

%   Copyright 2014-2015 The MathWorks, Inc.

y = 0.5 * erfc(-x / sqrt(2));
end
