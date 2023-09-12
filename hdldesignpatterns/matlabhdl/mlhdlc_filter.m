%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Simple FIR Filter
% 
% Hardware design concepts covered in this example: 
% (1) Implementation of a tap delay using an array of persistent variables
% (2) Filter coefficients as a constant array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2011-2015 The MathWorks, Inc.

function out=mlhdlc_filter(in)
persistent td c;
% Clear tap delay line at beginning
if isempty(c)
  c  = equiripple31_coeffs();   % initialize coefficients only once
  td = zeros(1,length(c));
end
% inner product
out = td * c;
% shift tap delay line
td= [in td(1:end-1)];



function coefficients = equiripple31_coeffs()

% Discrete-Time FIR Filter (real)    
% -------------------------------    
% Filter Structure  : Direct-Form FIR
% Filter Length     : 32             
% Stable            : Yes            
% Linear Phase      : Yes (Type 2)   
                                                            
coefficients = [ 0.01819189661180973                 
-0.00020198068746191122              
-0.02146625191854059                
-0.0091754169664394324               
 0.011778734616371613                
 0.0029864525104194                  
 0.0036966971210806044               
 0.021452380069355854                
-0.019858998768631467                
-0.074865777700867595                
 0.0071068418762367594               
 0.13061598078792638                 
 0.036086972465538908                
-0.16579014802853284                 
-0.10214483764018981                 
 0.1526595112366359                  
 0.1526595112366359                  
-0.10214483764018981                 
-0.16579014802853284                 
 0.036086972465538908                
 0.13061598078792638                 
 0.0071068418762367594               
-0.074865777700867595                
-0.019858998768631467                
 0.021452380069355854                
 0.0036966971210806044               
 0.0029864525104194                  
 0.011778734616371613                
-0.0091754169664394324               
-0.02146625191854059                 
-0.00020198068746191122              
 0.01819189661180973 ];

                                    

