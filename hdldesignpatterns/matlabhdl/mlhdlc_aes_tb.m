%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the Advanced Encryption/Decryption System
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mlhdlc_aes_tb

%   Copyright 2011-2018 The MathWorks, Inc.
    
    BS = 4;
    plaintext = uint8(zeros(BS*BS, 1));
    cipherkey= uint8(zeros(BS*BS, 1));
    rng('default'); % always default to known state 
    
    for i = 1:5
        fprintf('%d\n', i);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Generate random plain text and cipher key
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        plaintext = uint8(randbyte(size(plaintext)));
        cipherkey = uint8(randbyte(size(cipherkey)));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Encrypt plain text to cipher text with the cipher key
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ciphertext = mlhdlc_aes(plaintext, cipherkey);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Decrypt the cipher text back to plain text with the cipher key
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        newplaintext = mlhdlc_aesd(ciphertext, cipherkey);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Verify if the decrypted plain text matches the original plain
        % text
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Plain Text: %s\nCipher Key: %s\nCipher Text: %s\nDecrypted Plain Text:%s\n', ...
            hextostr(plaintext'), ...
            hextostr(cipherkey'), ...
            hextostr(ciphertext'), ...
            hextostr(newplaintext'));
        if(plaintext ~= newplaintext)
            fprintf('!!!!!The decrypted plain text does not match the original plain text.!!!!!\n');
        else
            fprintf('!!!!!Decrypted plain text matches the original text.!!!!!\n');
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate random bytes with given rsize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = randbyte(rszie)
	result = uint8(256.*rand(rszie));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert hex data to string interleaving spaces between the hex characters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = hextostr(in)
    str_hex = dec2hex(in);
    str_space=[str_hex,repmat(' ',size(str_hex,1),1)];
    str = reshape(str_space.',1,numel(str_space));
end
