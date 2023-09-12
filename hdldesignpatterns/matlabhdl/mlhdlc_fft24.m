function y = mlhdlc_fft24(x)
% 24-point FFT
N = 24;

% split up into top/mid/bottom by round-robin every 3rd sample
Buffer0=x((0:3:N-1)+1);
Buffer1=x((1:3:N-1)+1);
Buffer2=x((2:3:N-1)+1);

% compute 8 point FFT of each section
fft0 = fft8(Buffer0);
fft1 = fft8(Buffer1);
fft2 = fft8(Buffer2);

% make 3-copies of each 8-point fft
FFT0 = [fft0; fft0; fft0;];
FFT1 = [fft1; fft1; fft1;];
FFT2 = [fft2; fft2; fft2;];

[TWIDDLE1, TWIDDLE2] = generate_twiddle_lut_24;

% multiply by twiddle
FFTW0 = coder.hdl.pipeline(FFT0); % top portion doesn't get a twiddle
FFTW1 = coder.hdl.pipeline(complexGain(FFT1, TWIDDLE1));
FFTW2 = coder.hdl.pipeline(complexGain(FFT2, TWIDDLE2));

% add up results for final FFT
t1 = coder.hdl.pipeline(FFTW0 + FFTW1);
y = coder.hdl.pipeline(t1 + FFTW2);
end

function [TWIDDLE1, TWIDDLE2] = generate_twiddle_lut_24()

N = 24;

TWIDDLE1=exp(-1j*2*pi*(0:(N-1))/N).';
TWIDDLE2=exp(-1j*2*pi*2*(0:(N-1))/N).';

TWIDDLE1 = fi(make_exact(TWIDDLE1),1,18,16);
TWIDDLE2 = fi(make_exact(TWIDDLE2),1,18,16);

end

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



function x = fft_8(N, u)

nt = numerictype(u);

tu1 = fft4(N, u(1:4));
tu2 = fft4(N, u(5:8));

i = 1:4;
tw = twf(N, i-1);
twu = hdlfi_mul(tu2 , tw);
x = bfly2(tu1, twu, nt);
end

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
x = bfly2(tu1, twu, nt);
end


function x = bfly2(u, v, nt)
% Two element butterfly
% use sum_fm and sum_nt to clamp the result of addition

x = fi([bitshift(u + v, -1); bitshift(u - v, -1)], nt, hdlfimath);

end

function out = hdlfi_mul(in1, in2)
% Complex fi multiplication
% use mul_fm and mul_nt to clamp the result of multiplication

out = fi(in1 .* in2, fimath(in1));

end

function W = twf(N, k)
% complex roots of unity (N=32)
%W = exp(-2*pi*1i*k/N)

w_N = fi(exp(-2*pi*1i*(0:(N-1))/N).', hdlfimath);
W = w_N(k+1);

end

function y = complexGain(u, v)

%coder.inline('always')
y = coder.nullcopy(u);
for ii=coder.unroll(1:length(u))
    y(ii) = coder.hdl.pipeline(complexMul(u(ii),v(ii)));
end

end

function y = complexMul(u, v)

%coder.inline('always')
re_u = real(u);
im_u = imag(u);

re_v = real(v);
im_v = imag(v);

y_re = fi(coder.hdl.pipeline(re_u * re_v) - coder.hdl.pipeline(im_u * im_v), numerictype(u), fimath(u));
y_im = fi(coder.hdl.pipeline(re_u * im_v) + coder.hdl.pipeline(im_u * re_v), numerictype(u), fimath(u));

y = complex(y_re, y_im);

end