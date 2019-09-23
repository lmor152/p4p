function [x,F] = NonLinear_opt(Phi, guess, score, xgrid, ygrid, xyrange, d, maxit, funtol)
options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'iter',...
     'MaxIterations', maxit, 'FunctionTolerance', funtol);    
[x,F] = fminunc(@(Phi)error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d), Phi(:), options);
end

