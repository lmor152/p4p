function [f] = evaluate_point(d, x, y, xgrid, ygrid, xyrange, Phi)

%     evaluate Z for array of x,y
%     
%     Arguments:
%         d {int} -- degree of basis (2 or 3)
%         x {float} -- x coordinate of point
%         y {float} -- y coordinate of point
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x and y of point cloud
%         Phi {matrix} -- control lattice (model parameters) 
%     
%     Returns:
%         float -- predictions
%     
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get min x and y
    minM = xyrange(1);
    minN = xyrange(2);
    % evaluate min, max, and index of ensemble corresponding to each point
    [exmax, exmin, i] = find_gt(xgrid, x - minM);
    [eymax, eymin, j] = find_gt(ygrid, y - minN);
    % get local coordinates
    s = (x - minM - exmin)/ (exmax - exmin);
    t = (y - minN - eymin)/ (eymax - eymin);
    % evaluate point based on neighbourhood of control points 
    f = 0;
    for k = 0:d
        for l = 0:d
            try
                f = f + W(d, k, l, s, t) * Phi(i+k, j+l);
            catch
            end
        end
    end
end