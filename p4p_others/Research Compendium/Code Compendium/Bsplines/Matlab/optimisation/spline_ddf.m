function [hess] = spline_ddf(x, y, xgrid, ygrid, xyrange, Phi, d)
%     calculate surface second derivative
% 
%     Arguments:
%         x {float} -- x coordinate
%         y {float} -- y coordinate
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x,y of point cloud
%         Phi {matrix} -- control lattice
%         d {int} -- Basis degree (2 or 3)
% 
%     Returns:
%         matrix - surface second derivative 
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get min x,y coordinate in points
    minM = xyrange(1);
    minN = xyrange(2);
    % evaluate min, max, and index of ensemble corresponding to each point    
    [exmax, exmin, i] = find_gt(xgrid, x - minM);
    [eymax, eymin, j] = find_gt(ygrid, y - minN);
    % get local coordinates
    s = (x - minM - exmin)/ (exmax - exmin);
    t = (y - minN - eymin)/ (eymax - eymin);
    
    ddx2 = 0;
    ddy2 = 0;
    ddxy = 0;
    
    % evaluate surface second derivatives based on neighbourhood of control points 
    for k = 0:d
        for l = 0:d
            try
                ddx2 = ddx2 + ((ddBasis(d,k,s) * Basis(d,l,t) * Phi(i+k, j+l)) / ((exmax - exmin)^2));
                ddy2 = ddy2 + ((Basis(d,k,s) * ddBasis(d,l,t) * Phi(i+k, j+l)) / ((eymax - eymin)^2));
                ddxy = ddxy + ((dBasis(d,k,s) * dBasis(d,l,t) * Phi(i+k, j+l)) / ((exmax - exmin)*(eymax - eymin)));
            catch
            end
        end
    end
    
    % output hessian matrix
    hess = [ddx2, ddxy; ddxy, ddy2];
end
