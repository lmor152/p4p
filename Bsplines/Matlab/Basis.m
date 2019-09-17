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
