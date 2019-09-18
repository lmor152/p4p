function [x,F] = NonLinear_opt(Phi,guess, score, xgrid, ygrid, xyrange, d)
options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,...
    'CheckGradients', true, 'MaxIterations', 1);    
    [x,F] = fminunc(@(Phi)error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d), Phi, options);
end

