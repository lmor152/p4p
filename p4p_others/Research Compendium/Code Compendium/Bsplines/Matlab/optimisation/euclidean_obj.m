function [obj, jac, hess] = euclidean_obj(est, point, xgrid, ygrid, xyrange, Phi, d)
%     calculate euclidean error, with jacobian and hessian
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
%         float -- euclidean distance between point (x,y,z) and guess (x',y',f(x',y'))
%         array -- jacobian [dx, dy]
%         matrix -- hessian matrix [[d2x2, dxdy], [dxdy, d2y2]]
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % reshape control points into grid
    Phi = reshape(Phi, length(xgrid)+d-1, length(ygrid)+d-1);
    % evaluate z at x,y
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    % calculate euclidean distance
    obj = (point(1) - est(1))^2 + (point(2) - est(2))^2 + (point(3) - z)^2;
    % incorporate jacobian of surface
    if nargout > 1
        [jacx, jacy] = euclidean_jac(est, point, xgrid, ygrid, xyrange, Phi, d); 
        jac = [jacx, jacy];
    end
    % incorporate hessian of surface
    if nargout > 2
        hess = euclidean_hess(est,point, xgrid, ygrid, xyrange, Phi, d);    
    end
end
