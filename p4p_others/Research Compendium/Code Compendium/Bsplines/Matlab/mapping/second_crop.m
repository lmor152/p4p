function [texp, ntex] = second_crop(points, ntex, xgrid, ygrid, xyrange)
%     crop points based on control grid
%     
%     Arguments:
%         points {matrix} -- points
%         ntex {array} -- texture
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xygrid {array} -- min x and y of point cloud
% 
%     Returns:
%         matrix -- texpoints in world coordinates
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % set region of interest
    newxgrid = xgrid + xyrange(1);
    newygrid = ygrid + xyrange(2);
    
    % get boundary of ROI
    umin = min(newxgrid);
    umax = max(newxgrid);
    vmin = min(newygrid);
    vmax = max(newygrid);

    % create mask for ROI
    xlogic = (points(:,1) >= umin) & (points(:,1) <= umax);
    ylogic = (points(:,2) >= vmin) & (points(:,2) <= vmax);
    % filter points with ROI
    texp = points(xlogic & ylogic, :);
    ntex = ntex(xlogic & ylogic, :);
    %texp = [texp(:,1), texp(:,2)];

end
