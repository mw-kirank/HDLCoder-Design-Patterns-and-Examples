%

% Copyright 2013-2015 The MathWorks, Inc.

%% start on clean slate
fxpCfg = coder.config('fixpt');
fxpCfg.TestBenchName = 'mlhdlc_european_call_tb';
fxpCfg.TestNumerics = false; %true
fxpCfg.LogIOForComparisonPlotting = true;

%% Log
mathFcnGenCfg = coder.approximation('Function','log','Architecture','LookupTable','NumberOfPoints',50,'InterpolationDegree',3,'ErrorThreshold',1e-3);
mathFcnGenCfg.NumberOfPoints = 1e2;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;

fxpCfg.addApproximation(mathFcnGenCfg);

%% Exp
mathFcnGenCfg = coder.approximation('Function','exp');
mathFcnGenCfg.NumberOfPoints = 1e2;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;

fxpCfg.addApproximation(mathFcnGenCfg);

%% NormCDF
mathFcnGenCfg = coder.approximation('Function','normcdf');
mathFcnGenCfg.NumberOfPoints = 1e3;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
fxpCfg.addApproximation(mathFcnGenCfg);

%% Sqrt
mathFcnGenCfg = coder.approximation('Function','sqrt');
mathFcnGenCfg.NumberOfPoints = 1e3;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
fxpCfg.addApproximation(mathFcnGenCfg);

%% Custom Function Replacement
mathFcnGenCfg = coder.approximation('Function','mlhdlc_european_call_invdiv','Architecture','LookupTable');
mathFcnGenCfg.NumberOfPoints = 1e3;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
mathFcnGenCfg.CandidateFunction = @mlhdlc_european_call_invdiv;

fxpCfg.addApproximation(mathFcnGenCfg);

%% Float2Fixed & HDL Code Generation

hdlcfg = coder.config('hdl');
hdlcfg.DesignFunctionName = 'mlhdlc_european_call';
hdlcfg.TestBenchName = 'mlhdlc_european_call_tb';

% only F2F conversion
%codegen('-float2fixed',fxpCfg,'mlhdlc_european_call')

% do F2F followed by HDL code generation
hdlcfg.RegisterInputs = true;
hdlcfg.RegisterOutputs = true;
hdlcfg.GenerateHDLTestBench=false;
hdlcfg.SimulateGeneratedCode=true;

codegen('-float2fixed',fxpCfg,'-config',hdlcfg,'mlhdlc_european_call')
