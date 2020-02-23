function [dx,dy] = euclidean_jac(est,point, xgrid, ygrid, xyrange, Phi, d)
%     calculate jacobian of objective function
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
%         array - jacobian of objective function
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com
    
    % evaluate z
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    % get surface derivatives 
    [dfdx, dfdy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    % get derivatives of objective function
    dx = -2*(point(1) - est(1)) - 2*dfdx*(point(3) - z);
    dy = -2*(point(2) - est(2)) - 2*dfdy*(point(3) - z);
end

