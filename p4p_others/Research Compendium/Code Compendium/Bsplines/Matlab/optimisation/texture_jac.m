function [tex_dx, tex_dy] = texture_jac(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d)
%     Projection jacobian of objective function
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
%         float -- dx
%         float -- dy
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % evaluate z
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    % evaluate surface derivatives
    [dx, dy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    
    % equation - x
    xterm1 = 2*(est(1) - impoint(1)) + 2*z*dx;
    xterm2 = 2*((origin(1) - impoint(1)) + origin(3)*dx);
    xterm3 = ((origin(1)-impoint(1))*(est(1)-impoint(1)) + (origin(2)-impoint(2))*(est(2)-impoint(2)) + origin(3)*z);
    denom = (origin(1)-impoint(1))^2 + (origin(2)-impoint(2))^2 + origin(3)^2;
    tex_dx = xterm1 - xterm2*xterm3/denom;
    
    % equation - y
    yterm1 = 2*(est(2) - impoint(2)) + 2*z*dy;
    yterm2 = 2*((origin(2) - impoint(2)) + origin(3)*dy);
    yterm3 = ((origin(1)-impoint(1))*(est(1)-impoint(1)) + (origin(2)-impoint(2))*(est(2)-impoint(2)) + origin(3)*z);
    tex_dy = yterm1 - yterm2*yterm3/denom;    
end

