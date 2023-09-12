%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Advanced Decryption System (AES-128)
% [1] Advanced Encryption Standard (AES) (FIPS PUB 197)
%
% Key Design pattern covered in this example: 
% (1) This example uses fixed point and integer operators. 
% (2) Bitwise Operator support
%
%
% Note: This design is already in fixed point and suitable for HDL code
% generation. It is not advisable to run floating point to fixed point
% advisor on this design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2011-2015 The MathWorks, Inc.

%#codegen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AES-128 Decryption 
%
% ciphertext: encrypted text
% cipherkey:  key to Decrypt cipher text
% plaintext:  decrypted text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plaintext = mlhdlc_aesd(ciphertext, cipherkey)

    BS = 4;
    RS = 10;
    s = uint8(zeros(BS*BS, RS));
    k = uint8(zeros(BS*BS, RS));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extend all round keys
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k(:,1) = ExtendKeys(cipherkey, 1);
    for i = 1:RS-1
        k(:, i+1) = ExtendKeys(k(:, i), i+1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % First round
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    s(:,1) = bitxor(ciphertext, k(:, RS));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Second to tenth round
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:RS-1
        s(:, i+1) = rmainroundstate(s(:, i), k(:, RS-i));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Final round
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plaintext = rfinalround(s(:, RS), cipherkey);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Key extension
% Given initial key or the round key from the previous round via k_in and
% the round number as iter, outputs the key for the current round.
% For example, to calculate the round key for round 1, k_in is the initial
% key and iter is 1.
%
% k_in:  key from the previous round
% iter:  the round number, ranging from 1 to 10
% k_out: extended round key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function k_out = ExtendKeys(k_in, iter)

BS = 4;
sbox = [ ...
	hex2dec('63'), hex2dec('7c'), hex2dec('77'), hex2dec('7b'), hex2dec('f2'), hex2dec('6b'), hex2dec('6f'), hex2dec('c5'), hex2dec('30'), hex2dec('01'), hex2dec('67'), hex2dec('2b'), hex2dec('fe'), hex2dec('d7'), hex2dec('ab'), hex2dec('76'), ... %0
	hex2dec('ca'), hex2dec('82'), hex2dec('c9'), hex2dec('7d'), hex2dec('fa'), hex2dec('59'), hex2dec('47'), hex2dec('f0'), hex2dec('ad'), hex2dec('d4'), hex2dec('a2'), hex2dec('af'), hex2dec('9c'), hex2dec('a4'), hex2dec('72'), hex2dec('c0'), ... %1
	hex2dec('b7'), hex2dec('fd'), hex2dec('93'), hex2dec('26'), hex2dec('36'), hex2dec('3f'), hex2dec('f7'), hex2dec('cc'), hex2dec('34'), hex2dec('a5'), hex2dec('e5'), hex2dec('f1'), hex2dec('71'), hex2dec('d8'), hex2dec('31'), hex2dec('15'), ... %2
	hex2dec('04'), hex2dec('c7'), hex2dec('23'), hex2dec('c3'), hex2dec('18'), hex2dec('96'), hex2dec('05'), hex2dec('9a'), hex2dec('07'), hex2dec('12'), hex2dec('80'), hex2dec('e2'), hex2dec('eb'), hex2dec('27'), hex2dec('b2'), hex2dec('75'), ... %3
	hex2dec('09'), hex2dec('83'), hex2dec('2c'), hex2dec('1a'), hex2dec('1b'), hex2dec('6e'), hex2dec('5a'), hex2dec('a0'), hex2dec('52'), hex2dec('3b'), hex2dec('d6'), hex2dec('b3'), hex2dec('29'), hex2dec('e3'), hex2dec('2f'), hex2dec('84'), ... %4
	hex2dec('53'), hex2dec('d1'), hex2dec('00'), hex2dec('ed'), hex2dec('20'), hex2dec('fc'), hex2dec('b1'), hex2dec('5b'), hex2dec('6a'), hex2dec('cb'), hex2dec('be'), hex2dec('39'), hex2dec('4a'), hex2dec('4c'), hex2dec('58'), hex2dec('cf'), ... %5
	hex2dec('d0'), hex2dec('ef'), hex2dec('aa'), hex2dec('fb'), hex2dec('43'), hex2dec('4d'), hex2dec('33'), hex2dec('85'), hex2dec('45'), hex2dec('f9'), hex2dec('02'), hex2dec('7f'), hex2dec('50'), hex2dec('3c'), hex2dec('9f'), hex2dec('a8'), ... %6
	hex2dec('51'), hex2dec('a3'), hex2dec('40'), hex2dec('8f'), hex2dec('92'), hex2dec('9d'), hex2dec('38'), hex2dec('f5'), hex2dec('bc'), hex2dec('b6'), hex2dec('da'), hex2dec('21'), hex2dec('10'), hex2dec('ff'), hex2dec('f3'), hex2dec('d2'), ... %7
	hex2dec('cd'), hex2dec('0c'), hex2dec('13'), hex2dec('ec'), hex2dec('5f'), hex2dec('97'), hex2dec('44'), hex2dec('17'), hex2dec('c4'), hex2dec('a7'), hex2dec('7e'), hex2dec('3d'), hex2dec('64'), hex2dec('5d'), hex2dec('19'), hex2dec('73'), ... %8
	hex2dec('60'), hex2dec('81'), hex2dec('4f'), hex2dec('dc'), hex2dec('22'), hex2dec('2a'), hex2dec('90'), hex2dec('88'), hex2dec('46'), hex2dec('ee'), hex2dec('b8'), hex2dec('14'), hex2dec('de'), hex2dec('5e'), hex2dec('0b'), hex2dec('db'), ... %9
	hex2dec('e0'), hex2dec('32'), hex2dec('3a'), hex2dec('0a'), hex2dec('49'), hex2dec('06'), hex2dec('24'), hex2dec('5c'), hex2dec('c2'), hex2dec('d3'), hex2dec('ac'), hex2dec('62'), hex2dec('91'), hex2dec('95'), hex2dec('e4'), hex2dec('79'), ... %A
	hex2dec('e7'), hex2dec('c8'), hex2dec('37'), hex2dec('6d'), hex2dec('8d'), hex2dec('d5'), hex2dec('4e'), hex2dec('a9'), hex2dec('6c'), hex2dec('56'), hex2dec('f4'), hex2dec('ea'), hex2dec('65'), hex2dec('7a'), hex2dec('ae'), hex2dec('08'), ... %B
	hex2dec('ba'), hex2dec('78'), hex2dec('25'), hex2dec('2e'), hex2dec('1c'), hex2dec('a6'), hex2dec('b4'), hex2dec('c6'), hex2dec('e8'), hex2dec('dd'), hex2dec('74'), hex2dec('1f'), hex2dec('4b'), hex2dec('bd'), hex2dec('8b'), hex2dec('8a'), ... %C
	hex2dec('70'), hex2dec('3e'), hex2dec('b5'), hex2dec('66'), hex2dec('48'), hex2dec('03'), hex2dec('f6'), hex2dec('0e'), hex2dec('61'), hex2dec('35'), hex2dec('57'), hex2dec('b9'), hex2dec('86'), hex2dec('c1'), hex2dec('1d'), hex2dec('9e'), ... %D
	hex2dec('e1'), hex2dec('f8'), hex2dec('98'), hex2dec('11'), hex2dec('69'), hex2dec('d9'), hex2dec('8e'), hex2dec('94'), hex2dec('9b'), hex2dec('1e'), hex2dec('87'), hex2dec('e9'), hex2dec('ce'), hex2dec('55'), hex2dec('28'), hex2dec('df'), ... %E
	hex2dec('8c'), hex2dec('a1'), hex2dec('89'), hex2dec('0d'), hex2dec('bf'), hex2dec('e6'), hex2dec('42'), hex2dec('68'), hex2dec('41'), hex2dec('99'), hex2dec('2d'), hex2dec('0f'), hex2dec('b0'), hex2dec('54'), hex2dec('bb'), hex2dec('16')  ... %F
];

Rcon= uint8([ ...
	hex2dec('8d'), hex2dec('01'), hex2dec('02'), hex2dec('04'), hex2dec('08'), hex2dec('10'), hex2dec('20'), hex2dec('40'), hex2dec('80'), hex2dec('1b'), hex2dec('36'), hex2dec('6c'), hex2dec('d8'), hex2dec('ab'), hex2dec('4d'), hex2dec('9a'), ...
	hex2dec('2f'), hex2dec('5e'), hex2dec('bc'), hex2dec('63'), hex2dec('c6'), hex2dec('97'), hex2dec('35'), hex2dec('6a'), hex2dec('d4'), hex2dec('b3'), hex2dec('7d'), hex2dec('fa'), hex2dec('ef'), hex2dec('c5'), hex2dec('91'), hex2dec('39'), ...
	hex2dec('72'), hex2dec('e4'), hex2dec('d3'), hex2dec('bd'), hex2dec('61'), hex2dec('c2'), hex2dec('9f'), hex2dec('25'), hex2dec('4a'), hex2dec('94'), hex2dec('33'), hex2dec('66'), hex2dec('cc'), hex2dec('83'), hex2dec('1d'), hex2dec('3a'), ...
	hex2dec('74'), hex2dec('e8'), hex2dec('cb'), hex2dec('8d'), hex2dec('01'), hex2dec('02'), hex2dec('04'), hex2dec('08'), hex2dec('10'), hex2dec('20'), hex2dec('40'), hex2dec('80'), hex2dec('1b'), hex2dec('36'), hex2dec('6c'), hex2dec('d8'), ...
	hex2dec('ab'), hex2dec('4d'), hex2dec('9a'), hex2dec('2f'), hex2dec('5e'), hex2dec('bc'), hex2dec('63'), hex2dec('c6'), hex2dec('97'), hex2dec('35'), hex2dec('6a'), hex2dec('d4'), hex2dec('b3'), hex2dec('7d'), hex2dec('fa'), hex2dec('ef'), ...
	hex2dec('c5'), hex2dec('91'), hex2dec('39'), hex2dec('72'), hex2dec('e4'), hex2dec('d3'), hex2dec('bd'), hex2dec('61'), hex2dec('c2'), hex2dec('9f'), hex2dec('25'), hex2dec('4a'), hex2dec('94'), hex2dec('33'), hex2dec('66'), hex2dec('cc'), ...
	hex2dec('83'), hex2dec('1d'), hex2dec('3a'), hex2dec('74'), hex2dec('e8'), hex2dec('cb'), hex2dec('8d'), hex2dec('01'), hex2dec('02'), hex2dec('04'), hex2dec('08'), hex2dec('10'), hex2dec('20'), hex2dec('40'), hex2dec('80'), hex2dec('1b'), ...
	hex2dec('36'), hex2dec('6c'), hex2dec('d8'), hex2dec('ab'), hex2dec('4d'), hex2dec('9a'), hex2dec('2f'), hex2dec('5e'), hex2dec('bc'), hex2dec('63'), hex2dec('c6'), hex2dec('97'), hex2dec('35'), hex2dec('6a'), hex2dec('d4'), hex2dec('b3'), ...
	hex2dec('7d'), hex2dec('fa'), hex2dec('ef'), hex2dec('c5'), hex2dec('91'), hex2dec('39'), hex2dec('72'), hex2dec('e4'), hex2dec('d3'), hex2dec('bd'), hex2dec('61'), hex2dec('c2'), hex2dec('9f'), hex2dec('25'), hex2dec('4a'), hex2dec('94'), ...
	hex2dec('33'), hex2dec('66'), hex2dec('cc'), hex2dec('83'), hex2dec('1d'), hex2dec('3a'), hex2dec('74'), hex2dec('e8'), hex2dec('cb'), hex2dec('8d'), hex2dec('01'), hex2dec('02'), hex2dec('04'), hex2dec('08'), hex2dec('10'), hex2dec('20'), ...
	hex2dec('40'), hex2dec('80'), hex2dec('1b'), hex2dec('36'), hex2dec('6c'), hex2dec('d8'), hex2dec('ab'), hex2dec('4d'), hex2dec('9a'), hex2dec('2f'), hex2dec('5e'), hex2dec('bc'), hex2dec('63'), hex2dec('c6'), hex2dec('97'), hex2dec('35'), ...
	hex2dec('6a'), hex2dec('d4'), hex2dec('b3'), hex2dec('7d'), hex2dec('fa'), hex2dec('ef'), hex2dec('c5'), hex2dec('91'), hex2dec('39'), hex2dec('72'), hex2dec('e4'), hex2dec('d3'), hex2dec('bd'), hex2dec('61'), hex2dec('c2'), hex2dec('9f'), ...
	hex2dec('25'), hex2dec('4a'), hex2dec('94'), hex2dec('33'), hex2dec('66'), hex2dec('cc'), hex2dec('83'), hex2dec('1d'), hex2dec('3a'), hex2dec('74'), hex2dec('e8'), hex2dec('cb'), hex2dec('8d'), hex2dec('01'), hex2dec('02'), hex2dec('04'), ...
	hex2dec('08'), hex2dec('10'), hex2dec('20'), hex2dec('40'), hex2dec('80'), hex2dec('1b'), hex2dec('36'), hex2dec('6c'), hex2dec('d8'), hex2dec('ab'), hex2dec('4d'), hex2dec('9a'), hex2dec('2f'), hex2dec('5e'), hex2dec('bc'), hex2dec('63'), ...
	hex2dec('c6'), hex2dec('97'), hex2dec('35'), hex2dec('6a'), hex2dec('d4'), hex2dec('b3'), hex2dec('7d'), hex2dec('fa'), hex2dec('ef'), hex2dec('c5'), hex2dec('91'), hex2dec('39'), hex2dec('72'), hex2dec('e4'), hex2dec('d3'), hex2dec('bd'), ...
	hex2dec('61'), hex2dec('c2'), hex2dec('9f'), hex2dec('25'), hex2dec('4a'), hex2dec('94'), hex2dec('33'), hex2dec('66'), hex2dec('cc'), hex2dec('83'), hex2dec('1d'), hex2dec('3a'), hex2dec('74'), hex2dec('e8'), hex2dec('cb') ...
]);


k_out = uint8(zeros(BS*BS, 1));

% Pick the last column and rotate down by 1 (i.e. RotWord)
k_temp = [k_in((2-1)*BS + BS), k_in((3-1)*BS + BS), k_in((4-1)*BS + BS), k_in((1-1)*BS + BS)];
% Substitute RotWord with SBox
idx = uint16(k_temp) + 1;
k_temp1 = sbox(idx);
% Xor the substituted RotWord with Rcon(iter)
k_temp2 = [bitxor(k_temp1(1), Rcon(uint8(iter + 1))), k_temp1(2:BS)];

% Calculate the first column of the new round key 
k_out((1-1)*BS + 1) = bitxor(k_in((1-1)*BS + 1), k_temp2(1));
k_out((2-1)*BS + 1) = bitxor(k_in((2-1)*BS + 1), k_temp2(2));
k_out((3-1)*BS + 1) = bitxor(k_in((3-1)*BS + 1), k_temp2(3));
k_out((4-1)*BS + 1) = bitxor(k_in((4-1)*BS + 1), k_temp2(4));

% Calculated the rest columns of the new round key
for i = 2:BS
    k_out((1-1)*BS + i) = bitxor(k_in((1-1)*BS + i), k_out((1-1)*BS + i - 1));
    k_out((2-1)*BS + i) = bitxor(k_in((2-1)*BS + i), k_out((2-1)*BS + i - 1));
    k_out((3-1)*BS + i) = bitxor(k_in((3-1)*BS + i), k_out((3-1)*BS + i - 1));
    k_out((4-1)*BS + i) = bitxor(k_in((4-1)*BS + i), k_out((4-1)*BS + i - 1));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main reverse round state containing four steps:
% 1. RShiftRows
% 2. RSubTypes
% 3. Xor text with key
% 4. RMixColumns
%
% s_in:  text state from the previous round
% k_in:  initial key for the first round or 
%        extended round key for the other rounds
% s_out: text state to the next round
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = rmainroundstate(s_in, k_in)

    s1 = RShiftRows(s_in);
    s2 = RSubBytes(s1);
    s3 = bitxor(s2, k_in);
    s_out = RMixColumns(s3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final reverse round state containing three steps
% 1. RShiftRows
% 2. RSubTypes
% 3. Xor text with key
%
% s_in:  text state from the previous round
% k_in:  extended round key for the last round
% s_out: decrypted text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = rfinalround(s_in, k_in)

    s1 = RShiftRows(s_in);
    s2 = RSubBytes(s1);
    s_out = bitxor(s2, k_in);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reverse-ShiftRows step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = RShiftRows(s_in)

BS = 4;
s_out = uint8(zeros(BS*BS, 1));

s_out(1) = s_in(1); s_out(2) = s_in(2); s_out(3) = s_in(3); s_out(4) = s_in(4);
s_out(5) = s_in(8); s_out(6) = s_in(5); s_out(7) = s_in(6); s_out(8) = s_in(7);
s_out(9) = s_in(11); s_out(10) = s_in(12); s_out(11) = s_in(9); s_out(12) = s_in(10);
s_out(13) = s_in(14); s_out(14) = s_in(15); s_out(15) = s_in(16); s_out(16) = s_in(13);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reverse-SubBytes step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = RSubBytes(s_in)

BS = 4;
rsbox = [ ...
    hex2dec('52'), hex2dec('09'), hex2dec('6a'), hex2dec('d5'), hex2dec('30'), hex2dec('36'), hex2dec('a5'), hex2dec('38'), hex2dec('bf'), hex2dec('40'), hex2dec('a3'), hex2dec('9e'), hex2dec('81'), hex2dec('f3'), hex2dec('d7'), hex2dec('fb'), ...
    hex2dec('7c'), hex2dec('e3'), hex2dec('39'), hex2dec('82'), hex2dec('9b'), hex2dec('2f'), hex2dec('ff'), hex2dec('87'), hex2dec('34'), hex2dec('8e'), hex2dec('43'), hex2dec('44'), hex2dec('c4'), hex2dec('de'), hex2dec('e9'), hex2dec('cb'), ...
    hex2dec('54'), hex2dec('7b'), hex2dec('94'), hex2dec('32'), hex2dec('a6'), hex2dec('c2'), hex2dec('23'), hex2dec('3d'), hex2dec('ee'), hex2dec('4c'), hex2dec('95'), hex2dec('0b'), hex2dec('42'), hex2dec('fa'), hex2dec('c3'), hex2dec('4e'), ...
    hex2dec('08'), hex2dec('2e'), hex2dec('a1'), hex2dec('66'), hex2dec('28'), hex2dec('d9'), hex2dec('24'), hex2dec('b2'), hex2dec('76'), hex2dec('5b'), hex2dec('a2'), hex2dec('49'), hex2dec('6d'), hex2dec('8b'), hex2dec('d1'), hex2dec('25'), ...
    hex2dec('72'), hex2dec('f8'), hex2dec('f6'), hex2dec('64'), hex2dec('86'), hex2dec('68'), hex2dec('98'), hex2dec('16'), hex2dec('d4'), hex2dec('a4'), hex2dec('5c'), hex2dec('cc'), hex2dec('5d'), hex2dec('65'), hex2dec('b6'), hex2dec('92'), ...
    hex2dec('6c'), hex2dec('70'), hex2dec('48'), hex2dec('50'), hex2dec('fd'), hex2dec('ed'), hex2dec('b9'), hex2dec('da'), hex2dec('5e'), hex2dec('15'), hex2dec('46'), hex2dec('57'), hex2dec('a7'), hex2dec('8d'), hex2dec('9d'), hex2dec('84'), ...
    hex2dec('90'), hex2dec('d8'), hex2dec('ab'), hex2dec('00'), hex2dec('8c'), hex2dec('bc'), hex2dec('d3'), hex2dec('0a'), hex2dec('f7'), hex2dec('e4'), hex2dec('58'), hex2dec('05'), hex2dec('b8'), hex2dec('b3'), hex2dec('45'), hex2dec('06'), ...
    hex2dec('d0'), hex2dec('2c'), hex2dec('1e'), hex2dec('8f'), hex2dec('ca'), hex2dec('3f'), hex2dec('0f'), hex2dec('02'), hex2dec('c1'), hex2dec('af'), hex2dec('bd'), hex2dec('03'), hex2dec('01'), hex2dec('13'), hex2dec('8a'), hex2dec('6b'), ...
    hex2dec('3a'), hex2dec('91'), hex2dec('11'), hex2dec('41'), hex2dec('4f'), hex2dec('67'), hex2dec('dc'), hex2dec('ea'), hex2dec('97'), hex2dec('f2'), hex2dec('cf'), hex2dec('ce'), hex2dec('f0'), hex2dec('b4'), hex2dec('e6'), hex2dec('73'), ...
    hex2dec('96'), hex2dec('ac'), hex2dec('74'), hex2dec('22'), hex2dec('e7'), hex2dec('ad'), hex2dec('35'), hex2dec('85'), hex2dec('e2'), hex2dec('f9'), hex2dec('37'), hex2dec('e8'), hex2dec('1c'), hex2dec('75'), hex2dec('df'), hex2dec('6e'), ...
    hex2dec('47'), hex2dec('f1'), hex2dec('1a'), hex2dec('71'), hex2dec('1d'), hex2dec('29'), hex2dec('c5'), hex2dec('89'), hex2dec('6f'), hex2dec('b7'), hex2dec('62'), hex2dec('0e'), hex2dec('aa'), hex2dec('18'), hex2dec('be'), hex2dec('1b'), ...
    hex2dec('fc'), hex2dec('56'), hex2dec('3e'), hex2dec('4b'), hex2dec('c6'), hex2dec('d2'), hex2dec('79'), hex2dec('20'), hex2dec('9a'), hex2dec('db'), hex2dec('c0'), hex2dec('fe'), hex2dec('78'), hex2dec('cd'), hex2dec('5a'), hex2dec('f4'), ...
    hex2dec('1f'), hex2dec('dd'), hex2dec('a8'), hex2dec('33'), hex2dec('88'), hex2dec('07'), hex2dec('c7'), hex2dec('31'), hex2dec('b1'), hex2dec('12'), hex2dec('10'), hex2dec('59'), hex2dec('27'), hex2dec('80'), hex2dec('ec'), hex2dec('5f'), ...
    hex2dec('60'), hex2dec('51'), hex2dec('7f'), hex2dec('a9'), hex2dec('19'), hex2dec('b5'), hex2dec('4a'), hex2dec('0d'), hex2dec('2d'), hex2dec('e5'), hex2dec('7a'), hex2dec('9f'), hex2dec('93'), hex2dec('c9'), hex2dec('9c'), hex2dec('ef'), ...
    hex2dec('a0'), hex2dec('e0'), hex2dec('3b'), hex2dec('4d'), hex2dec('ae'), hex2dec('2a'), hex2dec('f5'), hex2dec('b0'), hex2dec('c8'), hex2dec('eb'), hex2dec('bb'), hex2dec('3c'), hex2dec('83'), hex2dec('53'), hex2dec('99'), hex2dec('61'), ...
    hex2dec('17'), hex2dec('2b'), hex2dec('04'), hex2dec('7e'), hex2dec('ba'), hex2dec('77'), hex2dec('d6'), hex2dec('26'), hex2dec('e1'), hex2dec('69'), hex2dec('14'), hex2dec('63'), hex2dec('55'), hex2dec('21'), hex2dec('0c'), hex2dec('7d')  ...
];

s_out = uint8(zeros(BS*BS, 1));

for i=1:BS
    for j=1:BS
        idx = uint16(s_in((i-1)*BS + j)) + 1;
        s_out((i-1)*BS + j) = rsbox(idx);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reverse-MixColumns step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = RMixColumns(s_in)

BS = 4;
s_out = uint8(zeros(BS*BS, 1));
e8 = uint8(zeros(BS, 1));

a1 = s_in;
b1 = bitsll(a1, 1);
c1 = bitget(a1, BS*2);
a2 = bitxor(b1, c1*hex2dec('1b')); % s_in * 2
b2 = bitsll(a2, 1);
c2 = bitget(a2, BS*2);
a4 = bitxor(b2, c2*hex2dec('1b')); % s_in * 2
b4 = bitsll(a4, 1);
c4 = bitget(a4, BS*2);
a8 = bitxor(b4, c4*hex2dec('1b')); % s_in * 2

for i = 1:BS
    e8(i) = bitxor(bitxor(a8((1-1)*BS + i), a8((2-1)*BS + i)), bitxor(a8((3-1)*BS + i), a8((4-1)*BS + i)));
    
    s_out((1-1)*BS + i) = bitxor(bitxor(bitxor(a4((1-1)*BS + i), a2((1-1)*BS + i)), bitxor(a2((2-1)*BS + i), a1((2-1)*BS + i))), bitxor(bitxor(a4((3-1)*BS + i), a1((3-1)*BS + i)), bitxor(a1((4-1)*BS + i), e8(i))));
    s_out((2-1)*BS + i) = bitxor(bitxor(bitxor(a4((2-1)*BS + i), a2((2-1)*BS + i)), bitxor(a2((3-1)*BS + i), a1((3-1)*BS + i))), bitxor(bitxor(a4((4-1)*BS + i), a1((4-1)*BS + i)), bitxor(a1((1-1)*BS + i), e8(i))));
    s_out((3-1)*BS + i) = bitxor(bitxor(bitxor(a4((3-1)*BS + i), a2((3-1)*BS + i)), bitxor(a2((4-1)*BS + i), a1((4-1)*BS + i))), bitxor(bitxor(a4((1-1)*BS + i), a1((1-1)*BS + i)), bitxor(a1((2-1)*BS + i), e8(i))));
    s_out((4-1)*BS + i) = bitxor(bitxor(bitxor(a4((4-1)*BS + i), a2((4-1)*BS + i)), bitxor(a2((1-1)*BS + i), a1((1-1)*BS + i))), bitxor(bitxor(a4((2-1)*BS + i), a1((2-1)*BS + i)), bitxor(a1((3-1)*BS + i), e8(i))));
end

end
