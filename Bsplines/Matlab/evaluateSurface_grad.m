function [u,v] = evaluateSurface_grad(d,X,Y,xgrid, ygrid, xyrange, Phi)
    u = zeros(size(X));
    v = zeros(size(X));
    for i = 1:size(u,1)
        for j = 1:size(u,2)
            [dx, dy] = spline_df(X(i,j), Y(i,j), xgrid, ygrid, xyrange, Phi, d);
            u(i,j) = dx;
            v(i,j) = dy;
        end
    end
end