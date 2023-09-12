function mlhdlc_comms_data_packet_tb
%

%   Copyright 2011-2015 The MathWorks, Inc.

% generate transmit data, note the first two bytes are the data length
numberBytes = 8; % this is total number of symbols
numberSymbols = numberBytes*8;
rng(1); % always default to known state
data = [floor(numberBytes/2^8) mod(numberBytes,2^8) ...
    round(rand(1,numberBytes-2)*255)];

% generate training data helper function
make_train_data('TRAIN_DATA');

% make sure training data is generated
pause(2)
[~] = which('TRAIN_DATA');

trainBits1 = TRAIN_DATA;
Nts = length(trainBits1);

make_pad_data('PAD_DATA');
pause(2)
[~] = which('PAD_DATA');
Npad = 2^9;

% Give number of samples, where the start of the sequence flag will be
% (indicated by a zero), as well as an output buffer for generated symbols
Nsamp = 1000;
Noffset = 20;
emptyFlagHold = ones(1,Nsamp); emptyFlagHold(Noffset) = 0;
symbolOutHold = zeros(1,Nsamp);

dataIndex = 1;
byteValue = 0;
diffOn = 1; % 0 - regular encoding, 1 - differential encoding
for i1 = 1:Nsamp
    emptyFlag = emptyFlagHold(i1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call to the design
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [symbolOut, reByte] = ...
        mlhdlc_comms_data_packet(emptyFlag, byteValue, numberSymbols, diffOn, Nts, Npad);
    
    % This set of code emulates the external FIFO interface
    if reByte == 1 % when high, pop a value off the input FIFO
        byteValue = data(dataIndex);
        dataIndex = dataIndex + 1;
    end
    symbolOutHold(i1) = symbolOut;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is all code to verify we did the encoding properly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% grad training data - not differentially encoded
symbolTrain = symbolOutHold(1+Noffset+Npad:Noffset+Npad+Nts);

% grab user data and decode if necessary
symbolEst = zeros(1,numberSymbols);
symbolPrev = trainBits1(end);
if diffOn == 0
    symbolData = ...
        symbolOutHold(1+Noffset+Npad+Nts:Noffset+Npad+Nts+numberSymbols); %#ok<NASGU>
else
    % decoding is simply comparing adjacent received symbols
    symbolTemp = ...
       symbolOutHold(1+Noffset+Npad+Nts:Noffset+Npad+Nts+numberSymbols+32);
    for i1 = 1:length(symbolTemp)
        if symbolTemp(i1) == symbolPrev
            symbolEst(i1) = 1;
        else
            symbolEst(i1) = 0;
        end
        symbolPrev = symbolTemp(i1);
    end
end

% training data
trainDataEst = symbolTrain(1:Nts);
trainDiff = abs(trainDataEst-trainBits1');

% user data
userDataEst = symbolEst(1:numberSymbols);
dataEst = zeros(1,numberBytes);
for i1 = 1:numberBytes
    y = userDataEst((i1-1)*8+1:i1*8);
    dataEst(i1) = bin2dec(char(y+48));
end
userDiff = abs(dataEst-data);    

disp(['Training Difference: ',num2str(sum(trainDiff)), ...
    ' User Data Difference: ',num2str(sum(userDiff))]);

% run it through and check CRC
genPoly = 69665;
c = symbolEst;
cEst = c(1,:);
cEst2 = [cEst(1:end-32) cEst(end-15:end)];
cEst = cEst2;

valueCRCc = 65535;
for i1 = 1:length(cEst)
    valueCRCsh1 = bitsll(uint16(valueCRCc), 1);
    valueCRCadd1 = bitor(uint16(valueCRCsh1), cEst(i1));
    leadValue = bitget( valueCRCadd1, 16);
    if (leadValue == 1)
        valueCRCxor = bitxor(uint16(valueCRCadd1), uint16(genPoly));
    else
        valueCRCxor = bitxor(uint16(valueCRCadd1), 0);
    end
    valueCRCc = valueCRCxor;
end
if valueCRCc == 0
    disp('CRC decoded correctly');
else
    disp('CRC check failed');
end

function make_train_data(filename)
x  = load('mlhdlc_dpack_train_data.txt');
fid = fopen([filename,'.m'],'w+');
fprintf(fid,['function y = ' filename '\n']);
fprintf(fid,'%%#codegen\n');
fprintf(fid,'y = [\n');
fprintf(fid,'%1.0e\n',x);
fprintf(fid,'];\n');
fclose(fid);

function make_pad_data(filename) 
rng(1);
x = round(rand(1,2^9));
fid = fopen([filename,'.m'],'w+');
fprintf(fid,['function y = ' filename '\n']);
fprintf(fid,'%%#codegen\n');
fprintf(fid,'y = [\n');
fprintf(fid,'%1.0e\n',x);
fprintf(fid,'];\n');
fclose(fid);


