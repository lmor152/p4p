function [ub, lb, i] = find_gt(a, x)
    for i = 1:length(a)
        if x < a(i)
            i = i - 1;
            break
        end
    end
    if i == length(a)
        ub = 2*a(end) - a(end-1);
        lb = a(end);
    elseif i < 1
        ub = a(1);
        lb = a(1) - a(2);
    else
        ub = a(i+1);
        lb = a(i);
    end
end