function [f] = evaluate_point(d, x, y, xgrid, ygrid, xyrange, Phi)
    minM = xyrange(1);
    minN = xyrange(2);
    [exmax, exmin, i] = find_gt(xgrid, x - minM);
    [eymax, eymin, j] = find_gt(ygrid, y - minN);
    if (i < 1) || (i >= length(xgrid)) || (j < 1) || (j>=length(ygrid))
        f = 0;
        return 
    end
    s = (x - minM - exmin)/ (exmax - exmin);
    t = (y - minN - eymin)/ (eymax - eymin);
    f = 0;
    for k = 0:d
        for l = 0:d
            f = f + W(d, k, l, s, t) * Phi(i+k, j+l);
        end
        
    end
end