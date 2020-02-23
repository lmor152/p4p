function [d2, jac, hess] = texture_obj(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d)
%     Projection objective function
%     
%     Arguments:
%         est {array} -- initial guess of (x',y')
%         origin {array} -- transformed origin
%         impoint {array} -- (x, y)
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x and y of point cloud
%         Phi {matrix} -- control lattice (model parameters) 
%         d {[2,3]} -- degree of basis (2 or 3)
% 
%     Returns:
%         float -- squared distance
%         array -- jacobian
%         matrix -- hessian
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % evaluate z 
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    % equation parts
    normv1 = (est(1)-impoint(1))^2 +  (est(2)-impoint(2))^2 + z^2;
    num = ((origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)) + origin(3)*z)^2;
    denom = (origin(1) - impoint(1))^2 + (origin(2) - impoint(2))^2 + origin(3)^2;
    % calculate d2
    d2 = normv1 - num/denom;
    
    % incorporate jacobian
    if nargout > 1
        [dx, dy] = texture_jac(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d);
        jac = [dx, dy];
    end
    % incorporate hessian
    if nargout > 2
        hess = texture_hess(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d);
    end
end

