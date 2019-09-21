function [hess] = spline_ddf(x, y, xgrid, ygrid, xyrange, Phi, d)
    minM = xyrange(1);
    minN = xyrange(2);
    [exmax, exmin, i] = find_gt(xgrid, x - minM);
    [eymax, eymin, j] = find_gt(ygrid, y - minN);
    s = (x - minM - exmin)/ (exmax - exmin);
    t = (y - minN - eymin)/ (eymax - eymin);
    
    ddx2 = 0;
    ddy2 = 0;
    ddxy = 0;
    
    for k = 0:d
        for l = 0:d
            try
                ddx2 = ddx2 + ((ddBasis(d,k,s) * Basis(d,l,t) * Phi(i+k, j+l)) / ((exmax - exmin)^2));
                ddy2 = ddy2 + ((Basis(d,k,s) * ddBasis(d,l,t) * Phi(i+k, j+l)) / ((eymax - eymin)^2));
                ddxy = ddxy + ((dBasis(d,k,s) * dBasis(d,l,t) * Phi(i+k, j+l)) / ((exmax - exmin)*(eymax - eymin)));
            catch
            end
        end
    end
    
    hess = [ddx2, ddxy; ddxy, ddy2];
end
