%#codegen
function [pixel_out] = mlhdlc_2DFIR(pixel_in)
%
% The 2D FIR algorithm maintains three line buffers. Each iteration the
% input pixel is pushed into the current line buffer that is being written to.
% The control logic rotates between these three buffers when it reaches the
% column boundary.
%
% Each buffer is followed by a shift register and data at the current
% column index is pushed into the shift register.
%
% At each iteration a 3x3 kernel of pixels is formed from the pixel input, shift
% registers and line buffer outputs.
%
% The kernel is multiplied by a 3x3 filter coefficient mask and the sum of
% the resultant values is computed as the pixel output.

%   Copyright 2011-2015 The MathWorks, Inc.

nRows = 260;
nCols = 260;
mask = [-0.1667 -0.6667 -0.1667 -0.6667 4.3333 -0.6667 -0.1667 -0.6667 -0.1667];

persistent row_count;
persistent col_count;
persistent t_minus_1_pixel;
persistent t_minus_2_pixel;
persistent t_minus_1_memrow1;
persistent t_minus_2_memrow1;
persistent t_minus_1_memrow2;
persistent t_minus_2_memrow2;
persistent t_minus_1_memrow3;
persistent t_minus_2_memrow3;
persistent mem_row_idx;
persistent mem_row1;
persistent mem_row2;
persistent mem_row3;

if isempty(t_minus_1_memrow3)
    t_minus_1_memrow3 = 0;
    t_minus_2_memrow3 = 0;
    t_minus_1_memrow2 = 0;
    t_minus_2_memrow2 = 0;
    t_minus_1_memrow1 = 0;
    t_minus_2_memrow1 = 0;
    row_count = 1;
    col_count = 1;
    t_minus_1_pixel = 0;
    t_minus_2_pixel = 0;
    mem_row_idx = 1;
    mem_row1 = zeros(1,nCols);
    mem_row2 = zeros(1,nCols);
    mem_row3 = zeros(1,nCols);
end

row_count_r=row_count;
col_count_r=col_count;
t_minus_1_pixel_r=t_minus_1_pixel;
t_minus_2_pixel_r=t_minus_2_pixel;
t_minus_1_memrow1_r=t_minus_1_memrow1;
t_minus_2_memrow1_r=t_minus_2_memrow1;
t_minus_1_memrow2_r=t_minus_1_memrow2;
t_minus_2_memrow2_r=t_minus_2_memrow2;
t_minus_1_memrow3_r=t_minus_1_memrow3;
t_minus_2_memrow3_r=t_minus_2_memrow3;
mem_row_idx_r = mem_row_idx;

write_col_idx = col_count_r;

current_mem_row1_data = mem_row1(write_col_idx);
current_mem_row2_data = mem_row2(write_col_idx);
current_mem_row3_data = mem_row3(write_col_idx);

if mem_row_idx_r==1
    top_row= [t_minus_2_memrow2_r t_minus_1_memrow2_r current_mem_row2_data];
    middle_row= [t_minus_2_memrow3_r t_minus_1_memrow3_r current_mem_row3_data];
elseif mem_row_idx_r==2
    top_row= [t_minus_2_memrow3_r t_minus_1_memrow3_r current_mem_row3_data];
    middle_row= [t_minus_2_memrow1_r t_minus_1_memrow1_r current_mem_row1_data];
else
    top_row= [t_minus_2_memrow1_r t_minus_1_memrow1_r current_mem_row1_data];
    middle_row= [t_minus_2_memrow2_r t_minus_1_memrow2_r current_mem_row2_data];
end

bottom_row = [ t_minus_2_pixel_r t_minus_1_pixel_r pixel_in];

kernel = [top_row middle_row bottom_row];
if col_count_r>=3 && row_count_r>=3
    %pixel_out=sum(operand.*mask);
    
    m1 = kernel(1) * mask(1);
    m2 = kernel(2) * mask(2);
    m3 = kernel(3) * mask(3);
    m4 = kernel(4) * mask(4);
    m5 = kernel(5) * mask(5);
    m6 = kernel(6) * mask(6);
    m7 = kernel(7) * mask(7);
    m8 = kernel(8) * mask(8);
    m9 = kernel(9) * mask(9);
    
    % tree of adders
    s1 = m1 + m2;
    s2 = m3 + m4;
    s3 = m5 + m6;
    s4 = m7 + m8;    
    s21 = s1 + s2;
    s22 = s3 + s4;    
    s31 = s21 + s22;    
    pixel_out = s31 + m9;            
else
    pixel_out=0;
end


if mem_row_idx_r==1
    mem_row1_write_data = pixel_in;
    mem_row2_write_data = current_mem_row2_data;
    mem_row3_write_data = current_mem_row3_data;
elseif mem_row_idx_r==2
    mem_row1_write_data = current_mem_row1_data;
    mem_row2_write_data = pixel_in;
    mem_row3_write_data = current_mem_row3_data;
else
    mem_row1_write_data = current_mem_row1_data;
    mem_row2_write_data = current_mem_row2_data;
    mem_row3_write_data = pixel_in;
end

mem_row1(write_col_idx)=mem_row1_write_data;
mem_row2(write_col_idx)=mem_row2_write_data;
mem_row3(write_col_idx)=mem_row3_write_data;

if  col_count_r==nCols
    %toggle memrow
    if mem_row_idx_r ==1
        mem_row_idx=2;
    elseif mem_row_idx_r ==2
        mem_row_idx=3;
    else
        mem_row_idx=1;
    end
end
t_minus_1_pixel = pixel_in;
t_minus_2_pixel = t_minus_1_pixel_r;

t_minus_1_memrow1=current_mem_row1_data;
t_minus_2_memrow1=t_minus_1_memrow1_r;

t_minus_1_memrow2=current_mem_row2_data;
t_minus_2_memrow2=t_minus_1_memrow2_r;

t_minus_1_memrow3=current_mem_row3_data;
t_minus_2_memrow3=t_minus_1_memrow3_r;

if col_count_r+1<=nCols
    col_count = col_count_r+1;
else
    col_count =  1;
    if row_count_r<nRows
        row_count = row_count_r+1;
    else
        row_count = 1;
    end
end

end