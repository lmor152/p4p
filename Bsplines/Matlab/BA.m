a = Basis(2,2,0.5);
b = dBasis(2,2,0.5);
[ub, lb, ind] = find_gt([1,2,3,4], 2.5)
%ls = vfind([1,2,3,4,5],[2,3])

function [f] = evaluate_point(d, x, y, xgrid, ygrid, xyrange, Phi)
    minM = xyrange(1);
    minN = xyrange(2);
    [exmax, exmin, i] = find_gt(xgrid, points(p,1) - minM);
    [eymax, eymin, j] = find_gt(ygrid, points(p,2) - minN);
    s = (points(p,1) - minM - exmin)/ (exmax - exmin);
    t = (points(p,2) - minN - eymin)/ (eymax - eymin);
    for i = 1:(d+1)
        for j = 1:(d+1)
            
end

function [Phi] = BA_control(d, points, xgrid, ygrid)
    minM = min(points(:,0));
    minN = min(points(:,1));
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
        
        for k = 1:(d+1)
            for l = 1:(d+1)
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

function [ls] = vfind(a, x)
    ls = zeros(length(x), 4);
    for i = 1:length(x)
        [ub, lb, ind] = find_gt(a, i);
        d = (i - lb)/ (ub - lb);
        ls(i,:) = [ub,  lb, ind, d];
    end
end

function [ub, lb, i] = find_gt(a, x)
    for i = 1:length(a)
        if x < a(i)
            break
        end
    end
    ub = a(i);
    lb = a(i-1);
    i = i - 1;
end

function [w2] = sumW2(d,s,t)
    w2 = 0;
    for i = 1:d
        for j = 1:d
            del = W(d, i, j, s, t);
            w2 = w2 + del;
        end
    end
end

function [w] = W(d, k, l, s, t)
    w = Basis(d,k,s) * Basis(d,l,t);
end

function [out] = Basis(d,k,t)
    assert(d == 2 | d ==3)
    assert(0 <= t & t <1)
    assert(k <= 3)
    if d == 2
        if k == 0
            out = ((1-t)^2)/2; 
        elseif k ==1
            out = (2*t*(1-t) + 1)/2;
        elseif k ==2
            out = t^2/2;
        end
    elseif d == 3
        if k == 0
            out = ((1-t)^3) / 6;
        elseif k ==1
            out = (t * t * (3 * t - 6) + 4) / 6;
        elseif k ==2
            out = (t * (t * (-3 * t + 3) + 3) + 1) / 6;
        elseif k ==3
            out = (t^3) / 6;
        end 
    end
end

function [out] = dBasis(d,k,t)
    assert(d == 2 | d ==3)
    assert(0 <= t & t <1)
    assert(k <= 3)
    if d == 2
        if k == 0
            out = t; 
        elseif k ==1
            out = -2*t + 1;
        elseif k ==2
            out = t;
        end
    elseif d == 3
        if k == 0
            out = (-(1 - t)^2)/2;
        elseif k ==1
            out = (t * (3 * t - 4))/2;
        elseif k ==2
            out = (t * (2 - 3 * t) + 1)/2;
        elseif k ==3
            out = (t^2) / 2;
        end 
    end
end
