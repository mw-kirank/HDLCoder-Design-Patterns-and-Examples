%test for mlhdlc_rx_fifo, note that at i1 = 1022, the buffer is full.

%   Copyright 2014-2015 The MathWorks, Inc.

mlhdlc_rx_fifo(0, 0, 0, 1, 1);

for i1 = 1:1030
    [dout(i1), empty(i1), byte_recieved(i1), full(i1), percentfull(i1)] = ...
        mlhdlc_rx_fifo(0, 1, i1, 0, 1);  %#ok<*SAGROW> %store the byte
        
    [dout(i1), empty(i1), byte_recieved(i1), full(i1), percentfull(i1)] = ...
        mlhdlc_rx_fifo(0, 0, i1, 0, 1);  %toggle store byte off
end

for i1 = 1031:2060
    [dout(i1), empty(i1), byte_recieved(i1), full(i1), percentfull(i1)] = ...
        mlhdlc_rx_fifo(1, 0, 0, 0, 1);  %get byte
    
    [dout(i1), empty(i1), byte_recieved(i1), full(i1), percentfull(i1)] = ...
        mlhdlc_rx_fifo(0, 0, 0, 0, 1);  %toggle get byte off
end

    [dout(2061), empty(2061), byte_recieved(2061), full(2061), percentfull(i1)] = ...
        mlhdlc_rx_fifo(0, 0, 0, 0, 1);