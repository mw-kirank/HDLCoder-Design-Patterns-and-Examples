clear mlhdlc_moving_average
clear
% Define test vector
noise_sine = (5*sin(2*pi*(linspace(0,1,100)))+5)+0.25*randn([1,100]);
test_vector = fi(noise_sine,0,8,4);
% Preallocate output
y = fi(zeros(size(test_vector)),0,8,4);
y2 = y;
% stream moving average (data/valid) (ready is optional in AXI Stream)
for i = 1:numel(test_vector)
    [y(i), validOut] = mlhdlc_moving_average(test_vector(i), true);
end
test_vector_fp = single(test_vector);
windowSizef = 25; 
b = (1/windowSizef)*ones(1,windowSizef);
a = 1;
%Find the moving average of the data and plot it against the original data.
yf = filter(b,a,test_vector_fp);

%compare filter function with stream implementation of the filter
plot(y)
hold on
plot(yf)