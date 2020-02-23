function [RMSE,SSE,error] = LinError(d, points, xgrid, ygrid, Phi)
%     calculate error of fit
%     
%     Arguments:
%         d {int} -- degree of basis 2 or 3
%         points {matrix} -- point cloud
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         Phi {matrix} -- control point lattice (model parameters)
%     
%     Returns:
%         RMSE -- root mean squared error
%         SSE -- sum of squared errors
%         error -- pred error for each point
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com    

    % get min x,y
    xyrange = [min(points(:,1)), min(points(:,2))];
    % evaluate x,y on surface
    pred = zeros(length(points), 1);
    for i = 1:length(points)
        pred(i) = evaluate_point(d, points(i,1), points(i,2), xgrid, ygrid, xyrange, Phi);
    end
    % evaluate depth errors
    error = pred - points(:,3);
    % evaluate RMSE and SSE
    RMSE = sqrt(mean(error.^2));
    SSE = sum(error.^2);
end