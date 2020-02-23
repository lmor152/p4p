function [u,v] = evaluateSurface_grad(d,X,Y,xgrid, ygrid, xyrange, Phi)
%     evaluate surface gradient for grid of x,y
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
%         matrix -- surface derivatives
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com 

    % set up matrix for dx and dy
    u = zeros(size(X));
    v = zeros(size(X));
    % evaluate surface derivative at each x,y
    for i = 1:size(u,1)
        for j = 1:size(u,2)
            [dx, dy] = spline_df(X(i,j), Y(i,j), xgrid, ygrid, xyrange, Phi, d);
            u(i,j) = dx;
            v(i,j) = dy;
        end
    end
end