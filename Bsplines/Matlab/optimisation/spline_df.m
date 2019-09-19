function [dx, dy] = spline_df(x, y, xgrid, ygrid, xyrange, Phi, d)
    minM = xyrange(1);
    minN = xyrange(2);
    [exmax, exmin, i] = find_gt(xgrid, x - minM);
    [eymax, eymin, j] = find_gt(ygrid, y - minN);
    s = (x - minM - exmin)/ (exmax - exmin);
    t = (y - minN - eymin)/ (eymax - eymin);
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
