function [ systematic_bits, tail_bits1, parity1, interleaved_data, tail_bits2, parity2 ] = LTE_Turbo_encoder( message, message_length )
%Assign the interleaver
interleaver = LTE_Turbo_interleaver(message_length);
interleaved_data = message(interleaver);
% Output calculation
[systematic_bits, tail_bits1, parity1] = constituent_encoder(message);
[interleaved_data, tail_bits2, parity2] = constituent_encoder(interleaved_data);   % change constituent_encoder to constituent_encoder2 to obtain asymmetric turbo encoder
% Display the results
disp(['systematic_bits = ' num2str(systematic_bits)]);
disp(['tail_bits1 = ' num2str(tail_bits1)]);
disp(['parity1 = ' num2str(parity1)]);
disp(['interleaved_data = ' num2str(interleaved_data)]);
disp(['tail_bits2 = ' num2str(tail_bits2)]);
disp(['parity2 = ' num2str(parity2)]);
end
