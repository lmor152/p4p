function [hessian] = texture_hess(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d)
%     Projection hessian of objective function
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
%         matrix -- hessian
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % evalute z
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    % evaluate surface derivatives
    [dx, dy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    % get surface hessian
    hess = spline_ddf(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    
    % equation -d2x2
    denom = (origin(1) - impoint(1))^2 + (origin(2) - impoint(2))^2 + origin(3)^2;
    xel1 = -(origin(3)*dx + origin(1) - impoint(1))^2;
    xel2 = -origin(3)*hess(1,1)*(origin(3)*z + (origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)));
    xel3 = dx^2 + z*hess(1,1) + 1;
    ddx2 = 2*(((xel1 + xel2)/ denom) + xel3);
    
    % equation -d2y2
    yel1 = -(origin(3)*dy + origin(2) - impoint(2))^2;
    yel2 = -origin(3)*hess(2,2)*(origin(3)*z + (origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)));
    yel3 = dy^2 + z*hess(2,2) + 1;
    ddy2 = 2*(((yel1 + yel2)/ denom) + yel3);    
    
    % equation - dxdy
    xyel1 = -2*origin(3)*hess(1,2)*(origin(3)*z + (origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)));
    xyel2 = -2*(origin(3)*dx + origin(1) - impoint(1))*(origin(3)*dy + origin(2) - impoint(2));
    xyel3 = 2*dx*dy + 2*z*hess(1,2);
    ddxy = xyel3 + (xyel1 + xyel2)/denom;
    
    % compile hessian
    hessian = [ddx2, ddxy; ddxy, ddy2];
end

