function [Z] = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, Phi)
%     evaluate Z for grid of x,y
%     
%     Arguments:
%         d {int} -- degree of basis (2 or 3)
%         x {matrix} -- x coordinate of point
%         y {matrix} -- y coordinate of point
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x and y of point cloud
%         Phi {matrix} -- control lattice (model parameters) 
%     
%     Returns:
%         matrix -- predictions
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com  

    % initiliase Z
    Z = zeros(size(X));
    % for every x,y in grid evaluate Z
    for i = 1:size(Z,1)
        for j = 1:size(Z,2)
            Z(i,j) = evaluate_point(d, X(i,j), Y(i,j), xgrid, ygrid, xyrange, Phi);
        end
    end
end