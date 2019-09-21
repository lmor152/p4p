function [f] = evaluate_point(d, x, y, xgrid, ygrid, xyrange, Phi)
    minM = xyrange(1);
    minN = xyrange(2);
    [exmax, exmin, i] = find_gt(xgrid, x - minM);
    [eymax, eymin, j] = find_gt(ygrid, y - minN);
    s = (x - minM - exmin)/ (exmax - exmin);
    t = (y - minN - eymin)/ (eymax - eymin);
    f = 0;
    for k = 0:d
        for l = 0:d
            try
                f = f + W(d, k, l, s, t) * Phi(i+k, j+l);
            catch
            end
        end
    end
end