%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data payload creation

%   Copyright 2014-2015 The MathWorks, Inc.

messageASCII = 'Hello World!';
message = double(unicode2native(messageASCII));
msgLength = length(message);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TX_FIFO core
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numBytesToFifo = 1;
tx_get_byte = 0;
tx_full = 0;
tx_byte_received = 0;
i1 = 1;

while (numBytesToFifo <= msgLength && ~tx_full)
    % first thing the processor does is clear the internal tx fifo
    if i1 == 1
        tx_reset_fifo = 1;
        mlhdlc_tx_fifo(0, 0, 0, tx_reset_fifo, 1);
    else
        tx_reset_fifo = 0;
    end
    if (i1 > 1)
        tx_data_in = message(numBytesToFifo);
        numBytesToFifo = numBytesToFifo + 1;
        tx_store_byte = 1;
        while (tx_byte_received == 0)
            [tx_data_out, tx_empty, tx_byte_received, tx_full, tx_bytes_available] = ...
                mlhdlc_tx_fifo(tx_get_byte, tx_store_byte, tx_data_in, tx_reset_fifo, 1);
        end
        tx_store_byte = 0;
        while (tx_byte_received == 1)
            [tx_data_out, tx_empty, tx_byte_received, tx_full, tx_bytes_available] = ...
                mlhdlc_tx_fifo(tx_get_byte, tx_store_byte, tx_data_in, tx_reset_fifo, 1);
        end
    end
    i1 = i1 + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transfer Bytes from TX FIFO to RX FIFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i1 = 1;

tx_get_byte = 0;
tx_store_byte = 0;
tx_data_in = 0;
tx_reset_fifo = 0;

rx_get_byte = 0;
rx_data_in = 0;
rx_reset_fifo = 0;

while (tx_bytes_available > 0)
        if i1 == 1
            rx_reset_fifo = 1;
            mlhdlc_rx_fifo(0, 0, 0, rx_reset_fifo, 1);
        else
            rx_reset_fifo = 0;
        end
        if (i1 > 1)
            tx_get_byte = 1;
            rx_store_byte = 1;
            [tx_data_out, tx_empty, tx_byte_received, tx_full, tx_bytes_available] = ...
                mlhdlc_tx_fifo(tx_get_byte, tx_store_byte, tx_data_in, tx_reset_fifo, 1);
            
            rx_data_in = tx_data_out;
            
            [rx_data_out, rx_empty, rx_byte_ready, rx_full, rx_bytes_available] = ...
                mlhdlc_rx_fifo(rx_get_byte, rx_store_byte, rx_data_in, rx_reset_fifo, 1);
        end
        i1 = i1 + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RX_FIFO core
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numBytesFromFifo = 1;
rx_store_byte = 0;
rx_byte_recieved = 0;
i1 = 1;
msgBytes = zeros(1,msgLength);

while (~rx_empty)
    % first thing the processor does is clear the internal rx fifo
    if (i1 > 1)
        rx_get_byte = 1;
        while (rx_byte_ready == 0)
            [rx_data_out, rx_empty, rx_byte_ready, rx_full, rx_bytes_available] = ...
                mlhdlc_rx_fifo(rx_get_byte, rx_store_byte, rx_data_in, rx_reset_fifo, 1);
        end
        msgBytes(i1-1) = rx_data_out;
        rx_get_byte = 0;
        while (rx_byte_ready == 1)
            [rx_data_out, rx_empty, rx_byte_ready, rx_full, rx_bytes_available] = ...
                mlhdlc_rx_fifo(rx_get_byte, rx_store_byte, rx_data_in, rx_reset_fifo, 1);
        end
    end
    i1 = i1 + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numRecBytes = numBytesFromFifo;
if sum(msgBytes-message) == 0
    disp('Received message correctly');
else
    disp('Received message incorrectly');
end    
native2unicode(msgBytes)



