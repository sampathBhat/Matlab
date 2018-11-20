%constituent SISO decoder
function extrinsic_uncoded_llrs = component_decoder1(apriori_uncoded_llrs, apriori_encoded_llrs)

    if(length(apriori_uncoded_llrs) ~= length(apriori_encoded_llrs))
        error('LLR sequences must have the same length');
    end


  
    %               FromState,  ToState,    UncodedBit, EncodedBit
    transitions =  [1,          1,          0,          0; 
                    2,          5,          0,          0; 
                    3,          6,          0,          1; 
                    4,          2,          0,          1; 
                    5,          3,          0,          1; 
                    6,          7,          0,          1; 
                    7,          8,          0,          0; 
                    8,          4,          0,          0; 
                    1,          5,          1,          1; 
                    2,          1,          1,          1; 
                    3,          2,          1,          0; 
                    4,          6,          1,          0; 
                    5,          7,          1,          0; 
                    6,          3,          1,          0; 
                    7,          4,          1,          1; 
                    8,          8,          1,          1];
               
    % Find the largest state index in the transitions matrix           
    % In this example, we have eight states since the code has three memory elements
    state_count = max(max(transitions(:,1)),max(transitions(:,2)));

    % Calculate the uncoded a priori transition log-confidences by adding the
    % log-confidences associated with each corresponding bit value.
    uncoded_gammas=zeros(size(transitions,1),length(apriori_uncoded_llrs));
    for bit_index = 1:length(apriori_uncoded_llrs)
       for transition_index = 1:size(transitions,1)
          if transitions(transition_index, 3)==0
              uncoded_gammas(transition_index, bit_index) = apriori_uncoded_llrs(bit_index); 
          end
       end
    end

    % Calculate the encoded a priori transition log-confidences by adding the
    % log-confidences associated with each corresponding bit value.
    encoded_gammas=zeros(size(transitions,1),length(apriori_uncoded_llrs));
    for bit_index = 1:length(apriori_uncoded_llrs)
       for transition_index = 1:size(transitions,1)
          if transitions(transition_index, 4)==0
              encoded_gammas(transition_index, bit_index) = apriori_encoded_llrs(bit_index); 
          end
       end
    end
    
    % Forward recursion to calculate state log-confidences.
    alphas=zeros(state_count,length(apriori_uncoded_llrs));
    alphas=alphas-inf;
    alphas(1,1)=0; % We know that this is the first state
    for bit_index = 2:length(apriori_uncoded_llrs)
       for transition_index = 1:size(transitions,1)
           alphas(transitions(transition_index,2),bit_index) = jac(alphas(transitions(transition_index,2),bit_index),alphas(transitions(transition_index,1),bit_index-1) + uncoded_gammas(transition_index, bit_index-1) + encoded_gammas(transition_index, bit_index-1));   
       end
    end

    % Backwards recursion to calculate state log-confidences.
    betas=zeros(state_count,length(apriori_uncoded_llrs));
    betas=betas-inf;
    betas(1,length(apriori_uncoded_llrs))=0; % We know that this is the last state because the trellis is terminated
    for bit_index = length(apriori_uncoded_llrs)-1:-1:1
       for transition_index = 1:size(transitions,1)
           betas(transitions(transition_index,1),bit_index) = jac(betas(transitions(transition_index,1),bit_index),betas(transitions(transition_index,2),bit_index+1) + uncoded_gammas(transition_index, bit_index+1) + encoded_gammas(transition_index, bit_index+1));   
       end
    end

    % Calculate uncoded extrinsic transition log-confidences.
    deltas=zeros(size(transitions,1),length(apriori_uncoded_llrs));
    for bit_index = 1:length(apriori_uncoded_llrs)
       for transition_index = 1:size(transitions,1)
           deltas(transition_index, bit_index) = alphas(transitions(transition_index,1),bit_index) + encoded_gammas(transition_index, bit_index) + betas(transitions(transition_index,2),bit_index);
       end
    end

    % Calculate the uncoded extrinsic LLRs.
    extrinsic_uncoded_llrs = zeros(1,length(apriori_uncoded_llrs));
    for bit_index = 1:length(apriori_uncoded_llrs)    
       prob0=-inf;
       prob1=-inf;
       for transition_index = 1:size(transitions,1)
           if transitions(transition_index,3)==0
               prob0 = jac(prob0, deltas(transition_index,bit_index));
           else
               prob1 = jac(prob1, deltas(transition_index,bit_index));
           end      
       end
       extrinsic_uncoded_llrs(bit_index) = prob0-prob1;
    end

end