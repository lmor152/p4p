function [Z] = evaluate_pointvec(d,x,y,xgrid, ygrid, xyrange, Phi)
%     evaluate Z for array of x,y
%     
%     Arguments:
%         d {int} -- degree of basis (2 or 3)
%         x {array} -- x coordinates of points
%         y {array} -- y coordinates of points
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x and y of point cloud
%         Phi {matrix} -- control lattice (model parameters) 
%     
%     Returns:
%         array -- predictions
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com  

    % initialise Z
    Z = zeros(length(x),1);
    % evaluate Z for every x,y
    for i = 1:length(x)
        Z(i) = evaluate_point(d, x(i), y(i), xgrid, ygrid, xyrange, Phi);
    end
end
