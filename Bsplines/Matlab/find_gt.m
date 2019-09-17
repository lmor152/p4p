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