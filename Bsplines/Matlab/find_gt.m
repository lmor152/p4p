function [ub, lb, i] = find_gt(a, x)
    for i = 1:length(a)
        if x < a(i)
            i = i - 1;
            break
        end
    end
    
    if i >= length(a) - 1
        ub = 2*a(end) - a(end-1);
        lb = a(end);
        i = i-1;
    elseif i < 1
        ub = a(1);
        lb = a(1) - a(2);
        i = i-1;
    else
        ub = a(i);
        lb = a(i-1);
        i = i - 1;
    end
end