function [f] = evaluate_point(d, x, y, xgrid, ygrid, xyrange, Phi)
    minM = xyrange(1);
    minN = xyrange(2);
    [exmax, exmin, i] = find_gt(xgrid, points(p,1) - minM);
    [eymax, eymin, j] = find_gt(ygrid, points(p,2) - minN);
    s = (points(p,1) - minM - exmin)/ (exmax - exmin);
    t = (points(p,2) - minN - eymin)/ (eymax - eymin);
    for k = 1:(d+1)
        for l = 1:(d+1)
            f = f + W(d, k, l, s, t) * Phi(i+k, j+l);
        end
    end        
end