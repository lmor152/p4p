function [x,F] = NonLinear_opt(Phi, guess, score, xgrid, ygrid, xyrange, d, maxit, funtol)
%     perform nonlinear optimisation
%     
%     Arguments:
%         Phi {matrix} -- control lattice
%         guess {matrix} -- estimate
%         score {matrix} -- points
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x,y of point cloud
%         d {int} -- Basis degree (2 or 3)
%         maxit -- max number of iterations for optimisation
%         funtol -- tolerance for optimisation
%     
%     Returns:
%         matrix -- new control point values
%         float -- sum of closest euclidean distances 
%     
    % set optimisation options
    options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'iter',...
         'MaxIterations', maxit, 'FunctionTolerance', funtol);   
    % run optmisation
    [x,F] = fminunc(@(Phi)error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d), Phi(:), options);
end

