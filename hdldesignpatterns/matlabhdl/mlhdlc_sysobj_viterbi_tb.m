% Viterbi_tb - testbench for Viterbi_dut

%   Copyright 2011-2015 The MathWorks, Inc.

numErrors = 0;
% rand stream
original_rs = RandStream.getGlobalStream;
rs = RandStream.create('mrg32k3a', 'seed', 25);
%RandStream.getGlobalStream(rs);
rs.reset;
% convolutional encoder
hConvEnc = comm.ConvolutionalEncoder;
% BER
hBER = comm.ErrorRate;
hBER.ReceiveDelay = 34;
reset(hBER);

% clear persistent variables in the design between runs of the testbench
clear mlhdlc_msysobj_viterbi;

for numSymbols = 1:10000
    % generate a random bit
    inputBit = logical(randi([0 1], 1, 1));
        
    % encode it with the Convolutional Encoder - rate 1/2
    encodedSymbol = step(hConvEnc, inputBit);
    
    % optional - add noise
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % call Viterbi Decoder DUT to decode the symbol
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vitdecOut = mlhdlc_sysobj_viterbi(encodedSymbol);
    
    ber = step(hBER, inputBit, vitdecOut);
end

fprintf('%s\n', repmat('%', 1, 38));
fprintf('%%%%%%%%%%%%%% %s %%%%%%%%%%%%%%\n', 'Viterbi Decoder Output');
fprintf('%s\n', repmat('%', 1, 38));
fprintf('Number of bits %d, BER %g\n', numSymbols, ber(1));
fprintf('%s\n', repmat('%', 1, 38));

% EOF