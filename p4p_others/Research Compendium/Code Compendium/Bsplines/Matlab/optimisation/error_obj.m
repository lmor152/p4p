function [E, jac, errors] = error_obj(est, points, xgrid, ygrid, xyrange, Phi, d)
%     calculate field objective function
%     
%     Arguments:
%         est {array} -- initial guess of (x',y')
%         point {array} -- data point (x,y,z)
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x,y of point cloud
%         Phi {matrix} -- control lattice
%         d {int} -- Basis degree (2 or 3)
%     
%     Returns:
%         float -- objective value
%         array -- jacobian
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % intialise empty array
    newX = zeros(size(points(:,1:2)));
    errors = zeros(length(points),1);
    flags = zeros(length(points),1);

    % set optimisation options
    options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'off', 'HessianFcn', 'objective');
    % run parallel
    % for every point search for closest euclidean distance
    parfor i = 1:length(points)
        [x,F,exitflag] = fminunc(@(x)euclidean_obj(x, points(i,:), xgrid, ygrid, xyrange, Phi, d), est(i,:), options);
        % store new x
        newX(i,:) = x;
        % store objetive value
        errors(i) = F;
        flags(i) = exitflag;
    end

    % incorporate jacobian
    if nargout > 1
        dPhi = field_jac(est, points, xgrid, ygrid, xyrange, Phi, d); 
        jac = dPhi(:);
    end
    
%     if nargout > 2
%         ddPhi = field_hess(est, points, xgrid, ygrid, xyrange, Phi, d);
%         hess = ddPhi;
%     end

    % sum errors
    E = sum(errors);
    % update guess
    global guess
    guess = newX;
    
end 

