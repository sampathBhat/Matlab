SNR = -5;
N0 = 1/(10^(SNR/10));
iteration_count = 8; % Choose the maximum number of decoding iterations to perform
chances = 4; % Choose how many iterations should fail before the iterations are stopped
disp(['SNR=' num2str(SNR)])


% For LTE interleaver
interleaved_output = LTE_Turbo_interleaver(40);
a = [1,1,1,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];
b=a(interleaved_output); % Encode them
[a,e,c] = constituent_encoder(a);
[b,f,d] = constituent_encoder(b);

% BPSK modulate them
a_tx = -2*(a-0.5);
c_tx = -2*(c-0.5);
d_tx = -2*(d-0.5);
e_tx = -2*(e-0.5);

 
f_tx = -2*(f-0.5);
% Send the BPSK signal over an AWGN channel
a_rx = a_tx + sqrt(N0/2)*(randn(size(a_tx))+1i*randn(size(a_tx)));
c_rx = c_tx + sqrt(N0/2)*(randn(size(c_tx))+1i*randn(size(c_tx)));
d_rx = d_tx + sqrt(N0/2)*(randn(size(d_tx))+1i*randn(size(d_tx)));
e_rx = e_tx + sqrt(N0/2)*(randn(size(e_tx))+1i*randn(size(e_tx)));
f_rx = f_tx + sqrt(N0/2)*(randn(size(f_tx))+1i*randn(size(f_tx)));
% BPSK demodulator
a_c = (abs(a_rx+1).^2-abs(a_rx-1).^2)/N0;
c_c = (abs(c_rx+1).^2-abs(c_rx-1).^2)/N0;
d_c = (abs(d_rx+1).^2-abs(d_rx-1).^2)/N0;
e_c = (abs(e_rx+1).^2-abs(e_rx-1).^2)/N0;
f_c = (abs(f_rx+1).^2-abs(f_rx-1).^2)/N0;
% Interleave the systematic LLRs
b_c = a_c(interleaved_output);
% We have no a priori information for the systematic bits in the first decoding iteration.
a_a = zeros(size(a));
% Start iterating.
best_IA = 0;
iteration_index = 1;
chance = 0;
% Iterate until the iterations stop improving the decoding or until the iteration limit is reached.
while chance < chances && iteration_index <= iteration_count
% Obtain the un-coded a priori input for component decoder 1.
y_a = [a_a+a_c,e_c];
% Perform decoding.
y_e = component_decoder1(y_a,c_c);
% Remove the LLRs corresponding to the tail bits.
a_e = y_e(1:length(a));
% Interleave.
b_a = a_e(interleaved_output);
% Obtain the un-coded a priori input for component decoder 2.
z_a = [b_a+b_c,f_c];
% Perform decoding.
z_e = component_decoder1(z_a,d_c);   % change component_decoder1 to component_decoder2 for asymmetric encoder-decoder setup.

 

% Remove the LLRs corresponding to the termination bits.
b_e = z_e(1:length(b));
% Deinterleave.
a_a(interleaved_output) = b_e;
% Obtain the a-posteriori LLRs.
a_p = a_a + a_c + a_e;
% Make a hard decision and see how many bit errors are present
errors = sum((a_p < 0) ~= a);
decoded_bits = a_p < 0;
disp(['iteration index = ' num2str(iteration_index)]);
disp(['errors = ' num2str(errors)]);
disp(['decoded_bits = ' num2str(decoded_bits)]);
if errors == 0
best_errors = 0;
% No need to carry on if all the errors have been r emoved.
% It is assumed that a CRC is used to detect that this has happened.
chance = chances;
else
% See how well the decoding has done.
IA = measure_mutual_information_averaging(a_a);
% Have we seen an improvement in this iteration?
if IA > best_IA
best_IA = IA;
best_errors = errors;
else
chance = chance + 1;
end
end
% Get ready for the next iteration.
iteration_index = iteration_index + 1;
end
