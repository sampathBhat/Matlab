% Measure the mutual information of some LLRs.
% mutual_information is a scalar in the range 0 to 1
function mutual_information = measure_mutual_information_averaging(llrs)
    P0 = exp(llrs)./(1+exp(llrs));
    P1 = 1-P0;
    entropies = -P0.*log2(P0)-P1.*log2(P1);
    mutual_information = 1-sum(entropies(~isnan(entropies)))/length(entropies);
end