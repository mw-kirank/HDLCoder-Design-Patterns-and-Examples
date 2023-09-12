%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Viterbi Decoder 
% 
% Key Design pattern covered in this example: 
% (1) Using comm system toolbox ViterbiDecoder function
% (2) The 'step' method can be called only per system object in a design iteration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2011-2015 The MathWorks, Inc.

function decodedBits = mlhdlc_sysobj_viterbi(inputSymbol)

persistent hVitDec;

if isempty(hVitDec)
    hVitDec = comm.ViterbiDecoder('InputFormat','Hard', 'OutputDataType', 'Logical');
end

decodedBits = step(hVitDec, inputSymbol);
