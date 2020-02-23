function [dx, dy] = spline_df(x, y, xgrid, ygrid, xyrange, Phi, d)
%     calculate surface derivative
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
%         array - surface derivatives
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
    % evaluate surface derivative based on neighbourhood of control points 
    dx = 0;
    dy = 0;
    for k = 0:d
        for l = 0:d
            try
                dx = dx + dBasis(d,k,s) * Basis(d,l,t) * Phi(i+k, j+l) / (exmax - exmin);
                dy = dy + Basis(d,k,s) * dBasis(d,l,t) * Phi(i+k, j+l) / (eymax - eymin);
            catch
            end
        end
    end
end
