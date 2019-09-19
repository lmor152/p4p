function [Phi] = BA_control(d, points, xgrid, ygrid)
    minM = min(points(:,1));
    minN = min(points(:,2));
    u = length(xgrid);
    v = length(ygrid);
    delta = zeros(u+d-1, v+d-1);
    omg = zeros(u+d-1, v+d-1);
    Phi = zeros(u+d-1, v+d-1);
    
    for p = 1:length(points)
        [exmax, exmin, i] = find_gt(xgrid, points(p,1) - minM);
        [eymax, eymin, j] = find_gt(ygrid, points(p,2) - minN);
        s = (points(p,1) - minM - exmin)/ (exmax - exmin);
        t = (points(p,2) - minN - eymin)/ (eymax - eymin);
        sumWab2 = sumW2(d, s, t);
        for k = 0:d
            for l = 0:d
                w_kl = W(d, k, l, s, t);
                Phi_kl = w_kl * points(p,3)/sumWab2;
                delta(i+k, j+l) = delta(i+k, j+l) + Phi_kl * w_kl^2;
                omg(i+k, j+l) = omg(i+k,j+l) + w_kl^2;
            end
        end
    end
    
    for i = 1:(u+d-1)
        for j = 1:(v+d-1)
            if omg(i,j) ~= 0
                Phi(i,j) = delta(i,j)/omg(i,j);
            end
        end
    end
end