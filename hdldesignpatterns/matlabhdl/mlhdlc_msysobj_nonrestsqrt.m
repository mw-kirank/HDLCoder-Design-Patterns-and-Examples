
%

%   Copyright 2014-2015 The MathWorks, Inc.

classdef (StrictDefaults)mlhdlc_msysobj_nonrestsqrt < matlab.System
% MLHDLC_MSYSOBJ_NONRESTSQRT non-restoring square root
%     
%   H = mlhdlc_msysobj_nonrestsqrt() creates a non-restoring square root
%   system object. This object allows you to calculate a generate a
%   fixed-point HDL square root engine using minimal area
%
%   H = mlhdlc_msysobj_nonrestsqrt('DTFloatSim', numerictype(0,W,F))
%   creates a non-restoring square root system object designed for use with
%   floating point simulation. The latency through the system object will
%   be equivalent to the specified numeric type.
%
%   Step method syntax:
%   
%   [DATA_O,VALID_O] = step(H, DATA_I,INIT_I);
%
%   Where DATA_I is the value to calculate the square root for, INIT_I is a
%   boolean flag indicating whether to load a new input data or calculate
%   the square root for the previously loaded data. DATA_O is the result
%   and VALID_O is a boolean flag indicating whether or not the result is
%   ready. If DATA_I is a floating point value, the object will use the
%   specified 'DTFloatSim' value to simulate the number of cycles required
%   to obtain a valid result
%
%   This algorithm is based on 'A new non-restoring square root algorithm
%   and its VLSI implementations' (Y. Li, et al)
%   
%   hdlram methods:
%
%   step     - Load a new value or iteratively calculate the square root of
%              a previously loaded value
%
%
%   Example:
%
%   H = mlhdlc_msysobj_nonrestsqrt();
%   Data_i = fi(pi,0,32,16);
%   [~,Vld] = step(H,Data_i,true); % load the new sample
%   while ~Vld
%       [Data_o, Vld] = step(H,Data_i, false); % iterate until valid
%   end
    properties (Nontunable, Access=private)              
        % Data types
        QO_DT; % Q output fixed point representation
        % Register representations for D,Q,R, counters, single bit
        D_DT; 
        R_DT; 
        Q_DT;
        CNTR_DT;
        BIT_DT;
        % fi math
        FM = hdlfimath;
    end
     properties (Nontunable)              
        % Floating point simulation mode
        FloatSim = false;
        DTFloatSim = numerictype(0,32,0);
    end
    properties (Access=private)
        % Registers
        D;
        Q;
        R;
        Vld;
        cntr;
        en;
    end
    methods
        function obj = mlhdlc_msysobj_nonrestsqrt(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj, D_i, ~)
            if isfloat(D_i) || obj.FloatSim
                obj.FloatSim = true;
                InputDT = obj.DTFloatSim;
            else
                InputDT = numerictype(D_i);    
            end
            i_wl = InputDT.WordLength;
            i_fl = InputDT.FractionLength;
            i_il = i_wl-i_fl;

            % Internal quotient size
            % must have an even number of both integer and fractional
            % bits for the internal representation        
            qi_il = ceil(i_il/2)+mod(ceil(i_il/2),2);
            qi_fl = ceil(i_fl/2)+mod(ceil(i_fl/2),2);
            qi_wl = qi_il+qi_fl;

            % Output quotient size
            qo_wl = ceil(i_wl/2);
            qo_il = ceil(i_il/2);
            qo_fl = qo_wl-qo_il;

            d_wl = qi_wl*2;
            d_fl = qi_fl*2;
            r_wl = qi_wl+2;
            cntr_wl = ceil(log2(qi_wl));

            obj.D_DT = numerictype(0,d_wl,d_fl);
            obj.R_DT = numerictype(0,r_wl,0);
            obj.Q_DT = numerictype(0,qi_wl,qi_fl);
            obj.QO_DT = numerictype(0,qo_wl,qo_fl);
            obj.CNTR_DT = numerictype(0,cntr_wl,0);
            obj.BIT_DT = numerictype(0,1,0);  

            obj.resetImpl;
        end
        
        function resetImpl(obj)            
            % Reset states
            if obj.FloatSim
                obj.D = 0;
                obj.Q = 0;
                obj.R = 0;
                obj.cntr = 0;
            else
                obj.D = fi(0,obj.D_DT, obj.FM);
                obj.Q = fi(0,obj.Q_DT,obj.FM);
                obj.R = fi(0,obj.R_DT,obj.FM);
                obj.cntr = fi(0,obj.CNTR_DT,obj.FM);
            end
            obj.Vld = false;
            obj.en = false;
        end
        
        function num = getNumOutputsImpl(~)
            num = 2;
        end
        
        function num = getNumInputsImpl(~)
            num = 2;
        end
        
        % Here is help
        function [Q_o, Valid_o] = stepImpl(obj, D_i,Init_i)
            
            % Convert from the internal to the external representation
            if obj.FloatSim
                Q_o = obj.Q;
            else
                Q_o = fi(obj.Q,obj.QO_DT, obj.FM);
            end

            Valid_o = obj.Vld;

            if (Init_i)
                % Load the data on the first cycle
                if obj.FloatSim
                    obj.D(:) = D_i;
                else
                    % Cast D_i to an integer and pad bit if necessary
                    obj.D(:) = fi(D_i,obj.D_DT);
                end
                obj.cntr(:) = obj.Q_DT.WordLength-1;
                obj.Q(:) = 0;
                obj.R(:) = 0;
                obj.Vld = false;
                obj.en = true;
            else
                % Iterate until the result is ready
                if (obj.cntr == 0 && obj.en)
                    obj.Vld = true;
                    obj.en = false;
                else
                    obj.Vld = false;
                end
                
                if obj.FloatSim
                    obj.Q(:) = sqrt(obj.D);
                    obj.cntr(:) = obj.cntr - 1;
                else
                    % Get the two MSB of the D register
                    Dmsb = bitsliceget(obj.D,obj.D_DT.WordLength,obj.D_DT.WordLength-1);
                    % Get all but the two MSB of the R register
                    Rlsb = bitsliceget(obj.R,obj.R_DT.WordLength-2,1);
                    % Get the sign bit of the R register
                    Rmsb = bitget(obj.R,obj.R_DT.WordLength);
                    OpA = bitconcat(Rlsb,Dmsb);
                    % Set bit 1 based on R's MSB
                    OpB = bitconcat(obj.Q,Rmsb,fi(1,obj.BIT_DT));
                    if (logical(Rmsb))    
                        % R is negative
                        Rnext = fi(OpA + OpB,obj.R_DT,obj.FM);
                    else
                        % R is positive
                        Rnext = fi(OpA - OpB,obj.R_DT,obj.FM);
                    end
                    % Get the sign bit of the add/sub output
                    Rnmsb = bitget(Rnext,obj.R_DT.WordLength);
                    % Set bit 1 based on R's MSB
                    Qnext = bitsll(obj.Q,1);
                    if (~logical(Rnmsb))
                        Qnext = bitset(Qnext,1,1); 
                    end
                    % Update the registers
                    obj.Q(:) = Qnext;
                    obj.R(:) = Rnext;
                    obj.D(:) = bitsll(obj.D,2);
                    obj.cntr(:) = obj.cntr - cast(1, 'like', obj.cntr);
                end
            end
        end
    end
end