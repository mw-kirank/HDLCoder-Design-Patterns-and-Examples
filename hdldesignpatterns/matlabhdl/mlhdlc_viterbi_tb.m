% mlhdlc_viterbi_tb: testbench for mlhdlc_viterbi

%   Copyright 2011-2015 The MathWorks, Inc.

numErrors = 0;
% rand stream
original_rs = RandStream.getGlobalStream;
rs = RandStream.create('mrg32k3a', 'seed', 25);
RandStream.setGlobalStream(rs);
rs.reset;
% convolutional encoder
hConvEnc = comm.ConvolutionalEncoder;
% BER
hBER = comm.ErrorRate;
hBER.ReceiveDelay = 34;
reset(hBER);

for numSymbols = 1:10000
    % generate a random bit
    inputBit = logical(randi([0 1], 1, 1));
        
    % encode it with the Convolutional Encoder - rate 1/2
    encodedSymbol = step(hConvEnc, inputBit);
    
    % optional - add noise
    
    eS = fi(encodedSymbol,0,3,0,hdlfimath);
    
    % call Viterbi Decoder DUT to decode the symbol
    vitdecOut = mlhdlc_viterbi(eS);
    
    ber = step(hBER, inputBit, vitdecOut);
end

fprintf('Number of bits %d, BER %g\n', numSymbols, ber(1));

% EOF