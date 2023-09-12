%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Data packetization
%
% Introduction: 
%
% This core is meant to illustrate packetization of a transmit sequence.
% There is a "pad" data section, which allows for the transmit amplifier to
% settle. This is then followed by a 65-bit training sequence. This is
% followed by the number of symbols beginning encoded into two bytes or
% 16-bits. This is then followed by a variable length data sequence and a
% CRC. All bits can optionally be differentially encoded.
%
% Key design pattern covered in this example:
% (1) Design illustrates the us of binary operands, such as bitxor
% (2) Shows how to properly segment persistent variables for register an
% BRAM access
% (3) Illustrates the use of fi math
% (4) Shows how to properly format and store ROM data, e.g., padData

%   Copyright 2011-2015 The MathWorks, Inc.

%#codegen
function [symbolOut, reByte] = ...
    mlhdlc_comms_data_packet(emptyFlag, byteValue, numberSymbols, diffOn, Nts, Npad)

persistent trainBits1 padData
persistent valueCRC crcVector bitPrev
persistent inPacketFlag  bitOfByteIndex symbolCount

fm = hdlfimath;
if isempty(symbolCount)
    symbolCount = 1;
    inPacketFlag = 0;
    valueCRC = fi(1, 0,16,0, fm);
    bitOfByteIndex = 1; 
    bitPrev = fi(1, 0,1,0, fm);
    crcVector = zeros(1,16);
end
if isempty(trainBits1)
    % data-set already exists
    trainBits1 = TRAIN_DATA;
    padData = PAD_DATA;
end

%genPoly = 69665;
genPoly = fi(65535, 0,16,0, fm);
byteUint8 = uint8(byteValue);

reByte = 0;
symbolOut = fi(0, 0,1,0, fm);

%the first condition is whether or not we're currently processing a packet
if inPacketFlag == 1
    bitOut = fi(0, 0,1,0, fm);
    if symbolCount <= Npad
        bitOut(:) = padData(symbolCount);
    elseif symbolCount <= Npad+Nts
        bitOut(:) = trainBits1(symbolCount-Npad);
    elseif symbolCount <= Npad+Nts+numberSymbols
        bitOut(:) = bitget(byteUint8,9-bitOfByteIndex);
        bitOfByteIndex = bitOfByteIndex + 1;
        if bitOfByteIndex == 9 && symbolCount < Npad+Nts+numberSymbols
            bitOfByteIndex = 1;
            reByte = 1; % we've exhausted this one so pop new one off
        end
    elseif symbolCount <= Npad+Nts+numberSymbols+16
        bitOut(:) = 0;
    elseif symbolCount <= Npad+Nts+numberSymbols+32
        bitOut(:) = crcVector(symbolCount-(Npad+Nts+numberSymbols+16));
    else
        inPacketFlag = 0; %we're done
    end
    
    %leadValue = 0;
    % here we have the bit going out so if past Nts+Npad then form CRC.
    % Note that we throw 16 zeros on the end in order to flush the CRC
    if symbolCount > Npad+Nts && symbolCount <= Npad+Nts+numberSymbols+16
        
        valueCRCsh1 = bitsll(valueCRC, 1);
        valueCRCadd1 = bitor(valueCRCsh1, fi(bitOut, 0,16,0, fm));
        leadValue = bitget(valueCRCadd1,16);
        if leadValue == 1
            valueCRCxor = bitxor(valueCRCadd1, genPoly);
        else
            valueCRCxor = valueCRCadd1;
        end
        valueCRC = valueCRCxor;
        if symbolCount == Npad+Nts+numberSymbols+16
            crcVector(:) = bitget( valueCRC, 16:-1:1);
        end
    end

    if diffOn == 0 || symbolCount <= Npad+Nts
        symbolOut(:) = bitOut;
    else
        if bitPrev == bitOut
            symbolOut(:) = 1;
        else
            symbolOut(:) = 0;
        end
    end
    bitPrev(:) = symbolOut;

    symbolCount = symbolCount + 1; %total number of symbols transmitted
else
    % we're not processing a packet and waiting for a new packet to arrive
    if emptyFlag == 0
        % reset everything
        inPacketFlag = 1;
        % toggle re to grab data
        reByte = 1;
        symbolCount = 1;
        bitOfByteIndex = 1;
        valueCRC(:) = 65535;
        bitPrev(:) = 0;
    end
end
	  
end
