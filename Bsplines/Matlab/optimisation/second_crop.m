function [texp, ntex] = second_crop(points, ntex, xgrid, ygrid, xyrange)
    newxgrid = xgrid + xyrange(1);
    newygrid = ygrid + xyrange(2);

    umin = min(newxgrid);
    umax = max(newxgrid);
    vmin = min(newygrid);
    vmax = max(newygrid);

    xlogic = (points(:,1) >= umin) & (points(:,1) <= umax);
    ylogic = (points(:,2) >= vmin) & (points(:,2) <= vmax);
    
    texp = points(xlogic & ylogic, :);
    ntex = ntex(xlogic & ylogic, :);
    %texp = [texp(:,1), texp(:,2)];

end
