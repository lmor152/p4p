function [hessian] = euclidean_hess(est,point, xgrid, ygrid, xyrange, Phi, d)
%     calculate hessian
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
%         array - hessian of objective function
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com     
    
    % evaluate z 
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    % evaluate surface derivative
    [dfdx, dfdy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    % evaluate surface second derivative
    [hess] = spline_ddf(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    % calculate second derivatives of objective function
    ddx2 = -2 * hess(1,1)*(point(3) - z) + 2*dfdx^2 + 2;
    ddy2 = -2 * hess(2,2)*(point(3) - z) + 2*dfdy^2 + 2;
    ddxy = -2 * hess(1,2)*(point(3) - z) + 2*dfdx*dfdy;
    % compile hessian matrix
    hessian = [ddx2, ddxy; ddxy, ddy2];
end

