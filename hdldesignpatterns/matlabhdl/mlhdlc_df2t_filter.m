%#codegen
function y = mlhdlc_df2t_filter(x)

%   Copyright 2011-2015 The MathWorks, Inc.

persistent z;
if isempty(z)
    % Filter states as a column vector
    z = zeros(2,1);
end

% Filter coefficients as constants
b = [0.29290771484375   0.585784912109375  0.292907714843750];
a = [1.0                0.0                0.171600341796875];

y    =  b(1)*x + z(1);
z(1) = (b(2)*x + z(2)) - a(2) * y;
z(2) =  b(3)*x - a(3) * y;

end
