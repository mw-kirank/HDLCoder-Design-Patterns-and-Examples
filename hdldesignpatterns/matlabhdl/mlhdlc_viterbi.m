%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed-Point Implementation of Viterbi Decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Note: You should skip floating-point to fixed-point conversion workflow 
% on this design.

%   Copyright 2011-2015 The MathWorks, Inc.

%#codegen
function y = mlhdlc_viterbi(u)
% Viterbi algorithm implemented

% u --> ufix3 [2x1]
% y --> boolean

persistent p1 p2 p3 p4 p5;
if isempty(p1)
    p1 = getfi(zeros(2, 1), 0, 3, 0);
    p2 = getfi(zeros(1, 4), 0, 4, 0);
    p3 = getfi(zeros(1, 64), 0, 1, 0);
    p4 = getfi(zeros(1, 1), 0, 8, 0);
    p5 = false;
end

% Branch metric unit
bm  = bmu_unit(p1);
p1 = u;

% Add compare select unit
[ao1, ao2] = acs_main(p2);
p2 = bm;

% Traceback unit
tbo = mtraceback_main(p3, p4);
p3 = ao1;
p4 = ao2;

y = p5;
p5 = tbo;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bm = bmu_unit(u)
%--------------------------------------------------------------------------
% Branch metric unit
%--------------------------------------------------------------------------

% input symbol
u1 = u(1);
u2 = u(2);

%--------------------------------------------------------------------------
% BMC (Branch Metric) Unit
% This block calculates the Branch Metric (Hamming distance) of input symbols.
% The input are the quantized fixed-point symbols in the form of ufix3.

% Input Value   Interpretation
% 
% 0          Most confident zero
% 1          Second most confident zero
% 2          Third most confident zero
% 3          Least confident zero
% 4          Least confident one
% 5          Third most confident one
% 6          Second most confident one
% 7          Most confident one

%--------------------------------------------------------------------------

bm_max = getfi(7, 0, 3, 0);

bm_t1 = getfi(bm_max - u1, 0, 3, 0);
bm_t2 = getfi(bm_max - u2, 0, 3, 0);

bm = getfi(zeros(1,4), 0, 4, 0);

%----------------------------
bm(1) = u1 + u2; 

%----------------------------
bm(2) = u1 + bm_t2; 

%----------------------------
bm(3) = bm_t1 + u2;

%----------------------------
bm(4) = bm_t1 + bm_t2;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [o1, o2] = acs_main(bm)
% ACS (Add compare and select)

persistent smf bmf od;
if isempty(smf)
    smf = getfi(zeros(1, 64), 0, 7, 0);
    bmf = getfi(zeros(1, 1), 0, 7, 0);
    od = getfi(zeros(64,6), 0, 1, 0);
end

[dec, nsm] = acs_fun(bm, bmf, smf);
last_col = od(:, 6);
o1 = last_col';

first_col = dec';
rest = od(:, 1:5);

od = [first_col, rest];

[idx, nbmf] = renormalize_sm(nsm);
o2 = idx;

% update state
smf = nsm;
bmf = nbmf;

end

function [dec, nsm]  = acs_fun(bm, bm_feedback, sm_reg)
%--------------------------------------------------------------------------
%  ACS (Add-Compare-Select) block
%--------------------------------------------------------------------------

bm_conv = bm + bm_feedback;

bm_adjust = getfi(bm_conv, 0, 7, 0);

[nsm, dec] = acsunitbutterfly(bm_adjust, sm_reg);
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IDX, bm_feedback]  = renormalize_sm(nsm)
%--------------------------------------------------------------------------
% Renormalize Block
% Finds the state with minimum path metric and outputs its index
% Renormalizes all the path metrics by subtracting the minimum metric
%--------------------------------------------------------------------------

% initialize 6 registers for pipelining purpose
persistent reg_delay1 reg_delay2 reg_delay3 reg_delay4 reg_delay5 reg_delay6
if isempty(reg_delay1)
    reg_delay1 = getfi(zeros(1, 64), 0, 7, 0);
    reg_delay2 = getfi(zeros(1, 64), 0, 7, 0);
    reg_delay3 = getfi(zeros(1, 64), 0, 7, 0);
    reg_delay4 = getfi(zeros(1, 64), 0, 7, 0);
    reg_delay5 = getfi(zeros(1, 64), 0, 7, 0);
    reg_delay6 = getfi(zeros(1, 64), 0, 7, 0);
end

% reverse the order of input vector
nsm_reverse = nsm(64:-1:1);

% insert pipelining registers
nsm_delay  = reg_delay6;
reg_delay6 = reg_delay5;
reg_delay5 = reg_delay4;
reg_delay4 = reg_delay3;
reg_delay3 = reg_delay2;
reg_delay2 = reg_delay1;
reg_delay1 = nsm_reverse;

%--------------------------------------------------------------------------
% Tree implementation min function for vector input of length 64
%--------------------------------------------------------------------------
[minimum, idx] = mtree_min(nsm_delay);

%--------------------------------------------------------------------------
% Renormalizes all the path metrics by subtracting the minimum metric
%--------------------------------------------------------------------------
if minimum < 32
    bm_feedback = getfi(0, 0, 7, 0);
else
    bm_feedback = getfi(124, 0, 7, 0);
end

index = getfi((idx-1), 0, 8, 0);
index_max = getfi(63, 0, 8, 0);
IDX = getfi(index_max - index, 0, 8, 0);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nsm, dec] = acsunitbutterfly(bm, sm)
%--------------------------------------------------------------------------
% ACS Unit Group(Add-Compare-Select)
% For each state in the trellis diagram, for each node in this state:
% 1. Add the branch metric to the paths merged to this node. 
% 2. Compare all the paths merged to this road
% 3. Select the path with the minimum path metric
%--------------------------------------------------------------------------

nsm = getfi(zeros(1,64),0, 7, 0);
dec = getfi(zeros(1,64),0, 1, 0);

%----------------------------------------------------
% 000000   -> 00 -> 000000   000001   -> 11 -> 000000   
%----------------------------------------------------
[nsm(1), dec(1)] = acsunit(bm(1),bm(4),sm(1),sm(2));
%----------------------------------------------------
% 000000   -> 11 -> 100000   000001   -> 00 -> 100000   
%----------------------------------------------------
[nsm(33), dec(33)] = acsunit(bm(4),bm(1),sm(1),sm(2));
%----------------------------------------------------
% 000010   -> 01 -> 000001   000011   -> 10 -> 000001   
%----------------------------------------------------
[nsm(2), dec(2)] = acsunit(bm(2),bm(3),sm(3),sm(4));
%----------------------------------------------------
% 000010   -> 10 -> 100001   000011   -> 01 -> 100001   
%----------------------------------------------------
[nsm(34), dec(34)] = acsunit(bm(3),bm(2),sm(3),sm(4));
%----------------------------------------------------
% 000100   -> 00 -> 000010   000101   -> 11 -> 000010   
%----------------------------------------------------
[nsm(3), dec(3)] = acsunit(bm(1),bm(4),sm(5),sm(6));
%----------------------------------------------------
% 000100   -> 11 -> 100010   000101   -> 00 -> 100010   
%----------------------------------------------------
[nsm(35), dec(35)] = acsunit(bm(4),bm(1),sm(5),sm(6));
%----------------------------------------------------
% 000110   -> 01 -> 000011   000111   -> 10 -> 000011   
%----------------------------------------------------
[nsm(4), dec(4)] = acsunit(bm(2),bm(3),sm(7),sm(8));
%----------------------------------------------------
% 000110   -> 10 -> 100011   000111   -> 01 -> 100011   
%----------------------------------------------------
[nsm(36), dec(36)] = acsunit(bm(3),bm(2),sm(7),sm(8));
%----------------------------------------------------
% 001000   -> 11 -> 000100   001001   -> 00 -> 000100   
%----------------------------------------------------
[nsm(5), dec(5)] = acsunit(bm(4),bm(1),sm(9),sm(10));
%----------------------------------------------------
% 001000   -> 00 -> 100100   001001   -> 11 -> 100100   
%----------------------------------------------------
[nsm(37), dec(37)] = acsunit(bm(1),bm(4),sm(9),sm(10));
%----------------------------------------------------
% 001010   -> 10 -> 000101   001011   -> 01 -> 000101   
%----------------------------------------------------
[nsm(6), dec(6)] = acsunit(bm(3),bm(2),sm(11),sm(12));
%----------------------------------------------------
% 001010   -> 01 -> 100101   001011   -> 10 -> 100101   
%----------------------------------------------------
[nsm(38), dec(38)] = acsunit(bm(2),bm(3),sm(11),sm(12));
%----------------------------------------------------
% 001100   -> 11 -> 000110   001101   -> 00 -> 000110   
%----------------------------------------------------
[nsm(7), dec(7)] = acsunit(bm(4),bm(1),sm(13),sm(14));
%----------------------------------------------------
% 001100   -> 00 -> 100110   001101   -> 11 -> 100110   
%----------------------------------------------------
[nsm(39), dec(39)] = acsunit(bm(1),bm(4),sm(13),sm(14));
%----------------------------------------------------
% 001110   -> 10 -> 000111   001111   -> 01 -> 000111   
%----------------------------------------------------
[nsm(8), dec(8)] = acsunit(bm(3),bm(2),sm(15),sm(16));
%----------------------------------------------------
% 001110   -> 01 -> 100111   001111   -> 10 -> 100111   
%----------------------------------------------------
[nsm(40), dec(40)] = acsunit(bm(2),bm(3),sm(15),sm(16));
%----------------------------------------------------
% 010000   -> 11 -> 001000   010001   -> 00 -> 001000   
%----------------------------------------------------
[nsm(9), dec(9)] = acsunit(bm(4),bm(1),sm(17),sm(18));
%----------------------------------------------------
% 010000   -> 00 -> 101000   010001   -> 11 -> 101000   
%----------------------------------------------------
[nsm(41), dec(41)] = acsunit(bm(1),bm(4),sm(17),sm(18));
%----------------------------------------------------
% 010010   -> 10 -> 001001   010011   -> 01 -> 001001   
%----------------------------------------------------
[nsm(10), dec(10)] = acsunit(bm(3),bm(2),sm(19),sm(20));
%----------------------------------------------------
% 010010   -> 01 -> 101001   010011   -> 10 -> 101001   
%----------------------------------------------------
[nsm(42), dec(42)] = acsunit(bm(2),bm(3),sm(19),sm(20));
%----------------------------------------------------
% 010100   -> 11 -> 001010   010101   -> 00 -> 001010   
%----------------------------------------------------
[nsm(11), dec(11)] = acsunit(bm(4),bm(1),sm(21),sm(22));
%----------------------------------------------------
% 010100   -> 00 -> 101010   010101   -> 11 -> 101010   
%----------------------------------------------------
[nsm(43), dec(43)] = acsunit(bm(1),bm(4),sm(21),sm(22));
%----------------------------------------------------
% 010110   -> 10 -> 001011   010111   -> 01 -> 001011   
%----------------------------------------------------
[nsm(12), dec(12)] = acsunit(bm(3),bm(2),sm(23),sm(24));
%----------------------------------------------------
% 010110   -> 01 -> 101011   010111   -> 10 -> 101011   
%----------------------------------------------------
[nsm(44), dec(44)] = acsunit(bm(2),bm(3),sm(23),sm(24));
%----------------------------------------------------
% 011000   -> 00 -> 001100   011001   -> 11 -> 001100   
%----------------------------------------------------
[nsm(13), dec(13)] = acsunit(bm(1),bm(4),sm(25),sm(26));
%----------------------------------------------------
% 011000   -> 11 -> 101100   011001   -> 00 -> 101100   
%----------------------------------------------------
[nsm(45), dec(45)] = acsunit(bm(4),bm(1),sm(25),sm(26));
%----------------------------------------------------
% 011010   -> 01 -> 001101   011011   -> 10 -> 001101   
%----------------------------------------------------
[nsm(14), dec(14)] = acsunit(bm(2),bm(3),sm(27),sm(28));
%----------------------------------------------------
% 011010   -> 10 -> 101101   011011   -> 01 -> 101101   
%----------------------------------------------------
[nsm(46), dec(46)] = acsunit(bm(3),bm(2),sm(27),sm(28));
%----------------------------------------------------
% 011100   -> 00 -> 001110   011101   -> 11 -> 001110   
%----------------------------------------------------
[nsm(15), dec(15)] = acsunit(bm(1),bm(4),sm(29),sm(30));
%----------------------------------------------------
% 011100   -> 11 -> 101110   011101   -> 00 -> 101110   
%----------------------------------------------------
[nsm(47), dec(47)] = acsunit(bm(4),bm(1),sm(29),sm(30));
%----------------------------------------------------
% 011110   -> 01 -> 001111   011111   -> 10 -> 001111   
%----------------------------------------------------
[nsm(16), dec(16)] = acsunit(bm(2),bm(3),sm(31),sm(32));
%----------------------------------------------------
% 011110   -> 10 -> 101111   011111   -> 01 -> 101111   
%----------------------------------------------------
[nsm(48), dec(48)] = acsunit(bm(3),bm(2),sm(31),sm(32));
%----------------------------------------------------
% 100000   -> 10 -> 010000   100001   -> 01 -> 010000   
%----------------------------------------------------
[nsm(17), dec(17)] = acsunit(bm(3),bm(2),sm(33),sm(34));
%----------------------------------------------------
% 100000   -> 01 -> 110000   100001   -> 10 -> 110000   
%----------------------------------------------------
[nsm(49), dec(49)] = acsunit(bm(2),bm(3),sm(33),sm(34));
%----------------------------------------------------
% 100010   -> 11 -> 010001   100011   -> 00 -> 010001   
%----------------------------------------------------
[nsm(18), dec(18)] = acsunit(bm(4),bm(1),sm(35),sm(36));
%----------------------------------------------------
% 100010   -> 00 -> 110001   100011   -> 11 -> 110001   
%----------------------------------------------------
[nsm(50), dec(50)] = acsunit(bm(1),bm(4),sm(35),sm(36));
%----------------------------------------------------
% 100100   -> 10 -> 010010   100101   -> 01 -> 010010   
%----------------------------------------------------
[nsm(19), dec(19)] = acsunit(bm(3),bm(2),sm(37),sm(38));
%----------------------------------------------------
% 100100   -> 01 -> 110010   100101   -> 10 -> 110010   
%----------------------------------------------------
[nsm(51), dec(51)] = acsunit(bm(2),bm(3),sm(37),sm(38));
%----------------------------------------------------
% 100110   -> 11 -> 010011   100111   -> 00 -> 010011   
%----------------------------------------------------
[nsm(20), dec(20)] = acsunit(bm(4),bm(1),sm(39),sm(40));
%----------------------------------------------------
% 100110   -> 00 -> 110011   100111   -> 11 -> 110011   
%----------------------------------------------------
[nsm(52), dec(52)] = acsunit(bm(1),bm(4),sm(39),sm(40));
%----------------------------------------------------
% 101000   -> 01 -> 010100   101001   -> 10 -> 010100   
%----------------------------------------------------
[nsm(21), dec(21)] = acsunit(bm(2),bm(3),sm(41),sm(42));
%----------------------------------------------------
% 101000   -> 10 -> 110100   101001   -> 01 -> 110100   
%----------------------------------------------------
[nsm(53), dec(53)] = acsunit(bm(3),bm(2),sm(41),sm(42));
%----------------------------------------------------
% 101010   -> 00 -> 010101   101011   -> 11 -> 010101   
%----------------------------------------------------
[nsm(22), dec(22)] = acsunit(bm(1),bm(4),sm(43),sm(44));
%----------------------------------------------------
% 101010   -> 11 -> 110101   101011   -> 00 -> 110101   
%----------------------------------------------------
[nsm(54), dec(54)] = acsunit(bm(4),bm(1),sm(43),sm(44));
%----------------------------------------------------
% 101100   -> 01 -> 010110   101101   -> 10 -> 010110   
%----------------------------------------------------
[nsm(23), dec(23)] = acsunit(bm(2),bm(3),sm(45),sm(46));
%----------------------------------------------------
% 101100   -> 10 -> 110110   101101   -> 01 -> 110110   
%----------------------------------------------------
[nsm(55), dec(55)] = acsunit(bm(3),bm(2),sm(45),sm(46));
%----------------------------------------------------
% 101110   -> 00 -> 010111   101111   -> 11 -> 010111   
%----------------------------------------------------
[nsm(24), dec(24)] = acsunit(bm(1),bm(4),sm(47),sm(48));
%----------------------------------------------------
% 101110   -> 11 -> 110111   101111   -> 00 -> 110111   
%----------------------------------------------------
[nsm(56), dec(56)] = acsunit(bm(4),bm(1),sm(47),sm(48));
%----------------------------------------------------
% 110000   -> 01 -> 011000   110001   -> 10 -> 011000   
%----------------------------------------------------
[nsm(25), dec(25)] = acsunit(bm(2),bm(3),sm(49),sm(50));
%----------------------------------------------------
% 110000   -> 10 -> 111000   110001   -> 01 -> 111000   
%----------------------------------------------------
[nsm(57), dec(57)] = acsunit(bm(3),bm(2),sm(49),sm(50));
%----------------------------------------------------
% 110010   -> 00 -> 011001   110011   -> 11 -> 011001   
%----------------------------------------------------
[nsm(26), dec(26)] = acsunit(bm(1),bm(4),sm(51),sm(52));
%----------------------------------------------------
% 110010   -> 11 -> 111001   110011   -> 00 -> 111001   
%----------------------------------------------------
[nsm(58), dec(58)] = acsunit(bm(4),bm(1),sm(51),sm(52));
%----------------------------------------------------
% 110100   -> 01 -> 011010   110101   -> 10 -> 011010   
%----------------------------------------------------
[nsm(27), dec(27)] = acsunit(bm(2),bm(3),sm(53),sm(54));
%----------------------------------------------------
% 110100   -> 10 -> 111010   110101   -> 01 -> 111010   
%----------------------------------------------------
[nsm(59), dec(59)] = acsunit(bm(3),bm(2),sm(53),sm(54));
%----------------------------------------------------
% 110110   -> 00 -> 011011   110111   -> 11 -> 011011   
%----------------------------------------------------
[nsm(28), dec(28)] = acsunit(bm(1),bm(4),sm(55),sm(56));
%----------------------------------------------------
% 110110   -> 11 -> 111011   110111   -> 00 -> 111011   
%----------------------------------------------------
[nsm(60), dec(60)] = acsunit(bm(4),bm(1),sm(55),sm(56));
%----------------------------------------------------
% 111000   -> 10 -> 011100   111001   -> 01 -> 011100   
%----------------------------------------------------
[nsm(29), dec(29)] = acsunit(bm(3),bm(2),sm(57),sm(58));
%----------------------------------------------------
% 111000   -> 01 -> 111100   111001   -> 10 -> 111100   
%----------------------------------------------------
[nsm(61), dec(61)] = acsunit(bm(2),bm(3),sm(57),sm(58));
%----------------------------------------------------
% 111010   -> 11 -> 011101   111011   -> 00 -> 011101   
%----------------------------------------------------
[nsm(30), dec(30)] = acsunit(bm(4),bm(1),sm(59),sm(60));
%----------------------------------------------------
% 111010   -> 00 -> 111101   111011   -> 11 -> 111101   
%----------------------------------------------------
[nsm(62), dec(62)] = acsunit(bm(1),bm(4),sm(59),sm(60));
%----------------------------------------------------
% 111100   -> 10 -> 011110   111101   -> 01 -> 011110   
%----------------------------------------------------
[nsm(31), dec(31)] = acsunit(bm(3),bm(2),sm(61),sm(62));
%----------------------------------------------------
% 111100   -> 01 -> 111110   111101   -> 10 -> 111110   
%----------------------------------------------------
[nsm(63), dec(63)] = acsunit(bm(2),bm(3),sm(61),sm(62));
%----------------------------------------------------
% 111110   -> 11 -> 011111   111111   -> 00 -> 011111   
%----------------------------------------------------
[nsm(32), dec(32)] = acsunit(bm(4),bm(1),sm(63),sm(64));
%----------------------------------------------------
% 111110   -> 00 -> 111111   111111   -> 11 -> 111111   
%----------------------------------------------------
[nsm(64), dec(64)] = acsunit(bm(1),bm(4),sm(63),sm(64));

end    
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [select_metric, decision] = acsunit(branch_metric0, branch_metric1, stored_metric0, stored_metric1)
% ACS (Add compare and select)

    % update branch0 metric
    a = getfi(branch_metric0 + stored_metric0, 0, 7, 0);

    % update branch1 metric
    b = getfi(branch_metric1 + stored_metric1, 0, 7, 0);
    
    % choose the metric
    if (a <= b)
        select_metric = a;
        decision = getfi(0, 0, 1, 0);
    else
        select_metric = b;
        decision = getfi(1, 0, 1, 0);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [minval, finalidx] = mtree_min(invec)
% Tree Min Implementation

% first level of comparison
inidx = int32(1:64);
[lvlonemin, lvloneidx] = vector_min(invec, inidx);

% second level of comparison
[lvltwomin, lvltwoidx] = vector_min(lvlonemin, lvloneidx);

% third level of comparison
[lvlthreemin, lvlthreeidx] = vector_min(lvltwomin, lvltwoidx);

% fourth level of comparison
[lvlfourmin, lvlfouridx] = vector_min(lvlthreemin, lvlthreeidx);

% fifth level of comparison
[lvlfivemin, lvlfiveidx] = vector_min(lvlfourmin, lvlfouridx);

% final comparison
[minval, idx] = vector_min(lvlfivemin, lvlfiveidx);

finalidx = uint8(idx);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Minimum subfuction for tree implementation
function [minvec, idxvec] = vector_min(invec, inidx)

coder.inline('always');

lengthminvec = bitshift(uint8(length(invec)), -1);
minvec = getfi(zeros(1, lengthminvec), 0, 7, 0);
idxvec = int32(zeros(1, lengthminvec));

for i=int32(1:lengthminvec)
    % get two consecutive values
    idx2 = int32(i)+int32(i); %i*2
    idx1 = int32(idx2) - int32(1); %i*2-1
    % get elements
    val1 = invec(idx1);
    val2 = invec(idx2);
    % compare them and select minimum
    if val1 <= val2
        minvec(i) = val1;
        idxvec(i) = inidx(idx1);
    else
        minvec(i) = val2;
        idxvec(i) = inidx(idx2);
    end
end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = mtraceback_main(dec, idx)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%--------------------------------------------------------------------------

persistent p2 p3 p4 p5 p6 p7 p8;
persistent i2 i3 i4 i5 i6 i7 i8 idxr;

if isempty(idxr)
    p2 = getfi(zeros(1, 64), 0, 1, 0);
    p3 = getfi(zeros(1, 64), 0, 1, 0);
    p4 = getfi(zeros(1, 64), 0, 1, 0);
    p5 = getfi(zeros(1, 64), 0, 1, 0);
    p6 = getfi(zeros(1, 64), 0, 1, 0);
    p7 = getfi(zeros(1, 64), 0, 1, 0);
    p8 = getfi(zeros(1, 64), 0, 1, 0);
    
    i2 = getfi(zeros(1, 1), 0, 8, 0);
    i3 = getfi(zeros(1, 1), 0, 8, 0);
    i4 = getfi(zeros(1, 1), 0, 8, 0);
    i5 = getfi(zeros(1, 1), 0, 8, 0);
    i6 = getfi(zeros(1, 1), 0, 8, 0);
    i7 = getfi(zeros(1, 1), 0, 8, 0);
    i8 = getfi(zeros(1, 1), 0, 8, 0);    
    idxr = getfi(zeros(1, 1), 0, 8, 0);      
end

[dec1, idx1] = mtraceback_unit1(dec, idx);

[dec2, idx2] = mtraceback_unit2(p2, i2);
p2 = dec1;
i2 = idx1;

[dec3, idx3] = mtraceback_unit3(p3, i3);
p3 = dec2;
i3 = idx2;

[dec4, idx4] = mtraceback_unit4(p4, i4);
p4 = dec3;
i4 = idx3;

[dec5, idx5] = mtraceback_unit5(p5, i5);
p5 = dec4;
i5 = idx4;

[dec6, idx6] = mtraceback_unit6(p6, i6);
p6 = dec5;
i6 = idx5;

[dec7, idx7] = mtraceback_unit7(p7, i7);
p7 = dec6;
i7 = idx6;

[~, idx8] = mtraceback_unit8(p8, i8);
p8 = dec7;
i8 = idx7;

y = get_tbu_out(idxr);
idxr = idx8;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = get_tbu_out(index)

coder.inline('always');

% the 6th bit of the 32th trace back step is the decoder output
tband = bitget(index, 6);
y =  logical(tband);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit1(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit2(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit3(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit4(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit5(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit6(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit7(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_out, index_out] = mtraceback_unit8(dec, index)
%--------------------------------------------------------------------------
% TBU (Trace Back Unit)
% Trace back unit restore the optimal path information stored in the 
% path metric register. The trace back depth of this decoder is 32 steps,
% which means every decoded symbol is based on the minimum path metric in the
% following 32 steps. 
%
% The trace back unit is implemented by a 32 stage shift register.
% In this pipelined model, 32 stage shift register is breaked into 8 4-stage shift registers. 
%--------------------------------------------------------------------------


fm = hdlfimath;

% initialize 4-stage trace back storage shift register
persistent tb_reg1 tb_reg2 tb_reg3 tb_reg4
if isempty(tb_reg1)
    tb_reg1 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg2)
    tb_reg2 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg3)
    tb_reg3 = getfi(zeros(1, 64), 0, 1, 0, fm);
end
if isempty(tb_reg4)
    tb_reg4 = getfi(zeros(1, 64), 0, 1, 0, fm);
end

% 4-stage trace back storage shift register
% stores path metric decision information from ACS unit
dec_out = tb_reg4;
tb_reg4 = tb_reg3;
tb_reg3 = tb_reg2;
tb_reg2 = tb_reg1;
tb_reg1 = dec;

% stage one
idx = int32(index) + int32(1);
tbread = tb_reg1(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage two
idx = int32(index) + int32(1);
tbread = tb_reg2(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage three
idx = int32(index) + int32(1);
tbread = tb_reg3(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index = bitconcat(getfi(0, 0, 2, 0), shift_idx);

% stage four
idx = int32(index) + int32(1);
tbread = tb_reg4(idx);
shift_idx = bitconcat(bitsliceget(index, 5, 1), tbread);
index_out = bitconcat(getfi(0, 0, 2, 0), shift_idx);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
function myfi = getfi(input, issigned, wlen, flen, fm)

coder.inline('always')

if nargin < 5
    fm = hdlfimath;
end

myfi = fi(input, issigned, wlen, flen, 'fimath', fm);

end