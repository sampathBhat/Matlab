function [systematic_bits, tail_bits, parity_bits] = constituent_encoder(message_bits)
systematic_bits = message_bits;
parity_bits = zeros(1,length(message_bits)+3);
tail_bits = zeros(1,3);
% Assign the all-zero state
q0 = 0;
q1 = 0;
q2 = 0;
for bit_index = 1:length(message_bits)
% Determine the next states
q0_plus = mod(message_bits(bit_index)+q1+q2, 2);
q1_plus = q0;
q2_plus = q1;
% Determine the parity bits
parity_bits(bit_index) = mod(q0_plus+q0+q2, 2);
% Assign the next state
q0 = q0_plus;
q1 = q1_plus;
q2 = q2_plus;
end
% Terminating the encoder
for bit_index = 1:3
% Determine the next state
q0_plus = 0;

 
q1_plus = q0;
q2_plus = q1;
% Determine the tail bits
tail_bits(bit_index) = mod(q1+q2, 2);
% Determine the parity bit
parity_bits(length(message_bits)+bit_index) = mod(q0_plus+q0+q2, 2);
% Assign the next state
q0 = q0_plus;
q1 = q1_plus;
q2 = q2_plus;
end
end
