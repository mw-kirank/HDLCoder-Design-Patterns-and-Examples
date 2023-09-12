function polyPhase_out = mlhdlc_fft_channelizer(current_input)
%

FIR_out = polyphaseFIRFrontend(current_input);
FFT_out = fft24_real(FIR_out);
polyPhase_out = phase_correction(FFT_out);

end
%-----
function FIR_out = polyphaseFIRFrontend(current_input)

persistent current_delayline coeffs LUT
vector_size = coder.const(12);
M = coder.const(24);
if isempty(current_delayline)
    current_delayline=zeros(vector_size*M,1, 'like', current_input);    % current delay line for computation
    coeffs = coder.load('coeffs.mat');
    LUT = coder.load('LUT.mat');
end

current_delayline=[current_delayline(vector_size+1:end);current_input]; % update delay line
reorder_current_delayline=current_delayline(LUT.LUT+1);   % reorder delay line for implementation indexing

currentx = reshape(reorder_current_delayline, vector_size, 24);
product = currentx .* coeffs.coeffs';
currenty = mtreesum_fcn(product);

FIR_out = zeros(1, 24, 'like', currenty);
FIR_out(:) = currenty;

end
%-----
function y = mtreesum_fcn(u)
%Implement the 'sum' function with fewer for loop iterations
%  y = sum(u);

coder.inline('always');

level1 = vsum(u);
level2 = vsum(level1);
level3 = vsum(level2);
level4 = vsum(level3);
y = level4;

end
%-----
function out = vsum(in)

coder.inline('always');

in2 = coder.hdl.pipeline(in(2:2:size(in,1), :));
in1 = coder.hdl.pipeline(in(1:2:size(in2,1)*2, :));
tmp = coder.hdl.pipeline(in1 + in2);

isodd = coder.const(mod(size(in,1),2) == 1);
if isodd
    out = [tmp; in(end, :)];
else
    out = tmp;
end

end
%-----
function y = fft24_real(x)
% fixed-point

% Reference https://www.dsprelated.com/showarticle/63.php

[TWIDDLE1, TWIDDLE2] = coder.const(@generate_twiddle_lut_24);

% split up into top/mid/bottom by round-robin every 3rd sample
topBuffer = x((0:3:23)+1); 
midBuffer = x((1:3:23)+1); 
bottomBuffer = x((2:3:23)+1);

% compute 8 point FFT of each section, and make 3 copies
topBufferFFT = fft8(topBuffer);
topFFT = [topBufferFFT; topBufferFFT; topBufferFFT];

midBufferFFT = fft8(midBuffer);
midFFT = [midBufferFFT; midBufferFFT; midBufferFFT];

bottomBufferFFT = fft8(bottomBuffer);
bottomFFT = [bottomBufferFFT; bottomBufferFFT; bottomBufferFFT];

% multiply by twiddle
topFFTW = coder.hdl.pipeline(topFFT(1:13)); % top portion doesn't get a twiddle
midFFTW = coder.hdl.pipeline(complexGain(midFFT(1:13),TWIDDLE1)); %midFFT(1:13).*TWIDDLE1;
bottomFFTW = coder.hdl.pipeline(complexGain(bottomFFT(1:13),TWIDDLE2)); %bottomFFT(1:13).*TWIDDLE2;

% add up results for final FFT
t1 = coder.hdl.pipeline(topFFTW+midFFTW);
y = coder.hdl.pipeline(t1+bottomFFTW);

end
%-----

function [TWIDDLE1, TWIDDLE2] = generate_twiddle_lut_24()

TWIDDLE1=exp(-1j*2*pi*(0:23)/24).';
TWIDDLE2=exp(-1j*2*pi*2*(0:23)/24).';

TWIDDLE1 = fi(make_exact(TWIDDLE1(1:13)),1,18,16);
TWIDDLE2 = fi(make_exact(TWIDDLE2(1:13)),1,18,16);

end
%-----
function [TWIDDLE]=make_exact(TWIDDLE)

for idx = 1:numel(TWIDDLE)
    E1=real(TWIDDLE(idx))-.5;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(.5,imag(TWIDDLE(idx)));
    end
    E1=real(TWIDDLE(idx))+.5;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(-.5,imag(TWIDDLE(idx)));
    end
    E1=real(TWIDDLE(idx))-1;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(1,0);
    end
    E1=real(TWIDDLE(idx))+1;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(-1,0);
    end
    E1=imag(TWIDDLE(idx))-.5;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(real(TWIDDLE(idx)),.5);
    end
    E1=imag(TWIDDLE(idx))+.5;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(real(TWIDDLE(idx)),-.5);
    end
    E1=imag(TWIDDLE(idx))-1;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(0,1);
    end
    E1=imag(TWIDDLE(idx))+1;
    if abs(E1)<1e-4
        TWIDDLE(idx)=complex(0,-1);
    end
end

end
%-----
function y  = fft8(u_r)
% 8 point FFT
% Real input and Complex output
% Cooley-Tukey
% Radix-2
% Decimation in Time

% N point FFT involves N/2 stages.
% 

N = 8;

%reverse input order
bitrevIdx = bitrevorder(1:N);
u = u_r(bitrevIdx);

y = fft_8(N, u);

end
%-----
function x = fft_8(N, u)

nt = numerictype(u);

tu1 = fft4(N, u(1:4));
tu2 = fft4(N, u(5:8));

i = 1:4;
tw = twf(N, i-1);
twu = hdlfi_mul(tu2 , tw);
x = bfly2(tu1, twu, nt);
end
%-----
%fft4
function x = fft4(N, u)

nt = numerictype(u);

tu1 = bfly2(u(1), u(2), nt);
tu2 = bfly2(u(3), u(4), nt);

% typical butterfly structure in an FFT
%
%    u0 --------------> tu0
%               \   /
%                \ /
%                 x
%                / \
%               /   \
%   u1 ---------------> tu1
%        tw         

i = 1:2;
tw = twf(N, (i-1)*2);
twu = hdlfi_mul(tu2 , tw);
x = coder.hdl.pipeline(bfly2(tu1, twu, nt));
end
%-----

function x = bfly2(u, v, nt)
% Two element butterfly
% use sum_fm and sum_nt to clamp the result of addition

x = fi([bitshift(u + v, -1); bitshift(u - v, -1)], nt, hdlfimath);

end
%-----
function out = hdlfi_mul(in1, in2)
% Complex fi multiplication
% use mul_fm and mul_nt to clamp the result of multiplication

out = coder.hdl.pipeline(fi(in1 .* in2, fimath(in1)));

end
%-----
function W = twf(N, k)
% complex roots of unity (N=32)
%W = exp(-2*pi*1i*k/N)

w_N = fi(exp(-2*pi*1i*(0:(N-1))/N).', hdlfimath);
W = w_N(k+1);

end
%-----
function y = complexGain(u, v)

re_u = real(u);
im_u = imag(u);

re_v = real(v);
im_v = imag(v);

y_re = fi(re_u .* re_v - im_u .* im_v, numerictype(u), fimath(u));
y_im = fi(re_u .* im_v + im_u .* re_v, numerictype(u), fimath(u));

y = complex(y_re, y_im);

end
%-----
function y = phase_correction(x)

persistent alternate
if isempty(alternate)
    alternate = false;
end

if alternate
    y = x;
    y(2:2:end) = -y(2:2:end);
else
    y = x;
end

alternate = ~alternate;

end
%-----
