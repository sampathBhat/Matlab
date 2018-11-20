% Jacobian logarithm
% If A = log(a) and B = log(b), then log(a+b) = max(A,B) + log(1+exp(-abs(A-B)))
% A, B and C are scalar LLRs
function C = jac(A,B)

    mode = 0; % Exact Jacobian logarithm
%	mode = 1; % Max-log MAP algorithm 
 

	if(A == -inf && B == -inf)
        C = -inf;
    else
        if mode == 0;
            C = max(A,B) + log(1+exp(-abs(A-B)));
        elseif mode == 1
        
            
            
        
        
            C = max(A,B);
        else
            error('Invalid Jacobian mode');
        end
	end
end
	