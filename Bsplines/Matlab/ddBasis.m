function [out] = ddBasis(d,k,t)
    assert(d == 2 | d ==3)
    assert(0 <= t & t <1)
    assert(k <= 3)
    if d == 2
        if k == 0
            out = 1; 
        elseif k ==1
            out = -2;
        elseif k ==2
            out = 1;
        end
    elseif d == 3
        if k == 0
            out = 1 - t;
        elseif k ==1
            out = 3 * t - 2;
        elseif k ==2
            out = 1 - 3*t;
        elseif k ==3
            out = t;
        end 
    end
end
