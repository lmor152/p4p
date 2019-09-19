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
            if (k+i < 1) || (j+l < 1) || (k+i > length(xgrid)+d-1) || (j+l > length(ygrid)+d-1)
                Phi_kl = 0;
            else
                Phi_kl = Phi(i+k, j+l);
            end
                dx = dx + dBasis(d,k,s) * Basis(d,l,t) *  Phi_kl / (exmax - exmin);
                dy = dy + Basis(d,k,s) * dBasis(d,l,t) * Phi_kl / (eymax - eymin);
        end
    end
end
