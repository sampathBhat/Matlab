    clear all
    frame_length = 800; % Choose your frame length K
    SNR_start = -5; % Choose the starting SNR
    SNR_delta = 1; % Choose the SNR hop
    SNR_stop = 2; % Choose the stopping SNR
%===============================================================
    
    
    iteration_count = 5; % Choose the maximum number of decoding iterations to perform
    chances = 3; % Choose how many iterations should fail to improve the decoding before the iterations are stopped early
    


    % Choose a file to save the results into.
    filename = ['results_',num2str(frame_length),'_',num2str(SNR_start),'.mat'];

       
   
    
    % Setup the SNR for the first iteration of the loop.
    SNR_count = 1;
    SNR = SNR_start;
    
    % Store the BER achieved after every iteration
    BERs = ones(1,iteration_count);
    
    % Loop until the job is killed or until the SNR target is reached.
    while SNR <= SNR_stop

        % Create a figure to plot the results.
        figure
        axes('YScale','log');
        title('BPSK modulation in an AWGN channel');
        ylabel('BER');
        xlabel('SNR (in dB)');
        if SNR_stop ~= inf
            xlim([SNR_start, SNR_stop]);
        end
        hold on
        
        % Convert from SNR (in dB) to noise power spectral density.
        N0 = 1/(10^(SNR/10));
        
        % Counters to store the number of errors and bits simulated so far.
        error_counts=zeros(1,iteration_count);
        bit_count=0;
               
        % Keep going until enough errors have been observed. 
        % This runs the simulation only as long as is required to keep the BER vs SNR curve smooth.
        while (bit_count < 1000 || error_counts(iteration_count) < 5) && bit_count < 700000
            
            interleaved_output = LTE_Turbo_interleaver(800);
a = round(rand(1,800));
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
z_e = component_decoder1(z_a,d_c);

 

% Remove the LLRs corresponding to the termination bits.
b_e = z_e(1:length(b));
% Deinterleave.
a_a(interleaved_output) = b_e;
% Obtain the a-posteriori LLRs.
a_p = a_a + a_c + a_e;


                % Make a hard decision and see how many bit errors we have.
                errors = sum((a_p < 0) ~= a);

                
                if errors == 0
                    best_errors = 0;
                    % No need to carry on if all the errors have been removed.
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
                
                % Accumulate the number of errors and bits that have been simulated so far.
                error_counts(iteration_index) = error_counts(iteration_index) + best_errors;
            
                % Get ready for the next iteration.
                iteration_index = iteration_index + 1;
            end
               
            while iteration_index <= iteration_count
                error_counts(iteration_index) = error_counts(iteration_index) + best_errors;
            
                iteration_index = iteration_index + 1;
            end
            
            bit_count = bit_count + length(a);
            
            % Store the SNR and BERs in a matrix and display it.
            results(SNR_count,1) = SNR;
            results(SNR_count,2) = bit_count;
            results(SNR_count,(1:iteration_count)+2) = error_counts

            % Save the results into a binary file. This avoids the loss of precision that is associated with ASCII files.
            save(filename, 'results', '-MAT');
            
        end
    
        % For every SNR considered so far, plot the BER obtained after each decoding iteration.
        for iteration_index = 1:iteration_count           
            semilogy(results(:,1),results(:,iteration_index+2)./results(:,2));
        end

        
        % Setup the SNR for the next iteration of the loop.
        SNR = SNR + SNR_delta;
        SNR_count = SNR_count + 1;
    end 

