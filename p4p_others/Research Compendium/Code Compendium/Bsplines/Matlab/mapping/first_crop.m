function [texp, ntex] = first_crop(points, tex, xgrid, ygrid, xyrange)
%    project image to model 
%     
%     Arguments:
%         points {matrix} -- points
%         tex {array} -- texture array 
%         xgrid {array} -- knots in x direction
%         ygrid {array} -- knots in y direction
%         xyrange {array} -- min x and y
%     
%     Returns:
%         texp -- points
%         ntex -- texture
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com  

    % set ROI
    newxgrid = xgrid + xyrange(1);
    newygrid = ygrid + xyrange(2);

    umin = min(newxgrid);
    umax = max(newxgrid);
    vmin = min(newygrid);
    vmax = max(newygrid);

    % create ROI mask for points 
    xlogic = (points(:,1) >= umin) & (points(:,1) <= umax);
    ylogic = (points(:,2) >= vmin) & (points(:,2) <= vmax);
    
    % filter points in ROI
    texp = points(xlogic & ylogic, :);
    ntex = repmat(tex(xlogic & ylogic),1,3)/255;
    %texp = [texp(:,1), texp(:,2)];

end

