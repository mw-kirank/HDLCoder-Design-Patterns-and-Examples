function mlhdlc_kalman_hdl_tb
% Figure setup

%   Copyright 2011-2015 The MathWorks, Inc.

fprintf(1, 'Running --------> %s\n\n', mfilename);

clear mlhdlc_kalman_hdl
plot_trajectory; % Clear plot data
generateData('clear') % Clear state

numPts = 300;
figure('Name', [mfilename, '_plot']);
hold;
grid;

dv_out = 0;

% Kalman filter loop
for idx = 1: numPts
    % Generate the location data
    z = generateData;

    % Use Kalman filter to estimate the location
    while (~dv_out)
        [y1, y2, dv_out] = mlhdlc_kalman_hdl(z);
    end

    dv_out = 0;
    
    y = [y1; y2];

    % Plot the results
    plot_trajectory(z,y, mfilename);
end
hold;
end

function z = generateData(~)

persistent X

if nargin == 1
    X = [];
    return;
end

dt=1;
A=[ 1 0 dt 0 0 0;...
    0 1 0 dt 0 0;...
    0 0 1 0 dt 0;...
    0 0 0 1 0 dt;...
    0 0 0 0 1 0 ;...
    0 0 0 0 0 1 ];

H = [ 1 0 0 0 0 0; 0 1 0 0 0 0 ];

% Add noise to the data
reset(RandStream.getGlobalStream);


if isempty(X)
    % X = [x, y, vx, vy, ax, ay]'
    X = [ -1 0.8 0.01 0 0 -0.0015]';
end

hzcoef=1e-7;
X = A * X + hzcoef* rand(6, 1);

% Bounce loss
bc = 0.8;

% When the target is moving out of the visible area, bounce it back
% Hit right
if (X(1) < -1 && X(3) < 0)
    X(1) = -X(1) - 2;
    X(3) = bc*-X(3);
end

% Hit left
if (X(1) > 1 && X(3) > 0)
    X(1) = -X(1) + 2;
    X(3) = bc*-X(3);
end

% Hit bottom
if (X(2) < -1 && X(4) < 0)
    X(2) = -X(2) - 2;
    X(4) = bc*-X(4);
end

% Hit top
if (X(2) > 1 && X(4) > 0)
    X(2) = -X(2) + 2;
    X(4) = bc*-X(4);
end


          
z = H * X + 0.05 * rand(2, 1);

end

function plot_trajectory(z,y, ~)

% figure('Name', [mf, '_plot']);
% hold on;

persistent h

if nargin == 0
    h = [];
    return;
end

if isempty(h)
    h = plot(z(1),z(2),'bo-');
    plot(y(1),y(2),'rx-');
    xlabel('horizontal position');
    ylabel('vertical position');
    axis([-1.1, 1.1, -1.1, 1.1]);
    
    title('Trajectory of object [blue] its Kalman estimate[red]');
    
end


plot(z(1), z(2), 'bo-');
plot(y(1), y(2), 'rx-');
drawnow;
end