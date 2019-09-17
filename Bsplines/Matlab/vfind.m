function [ls] = vfind(a, x)
    ls = zeros(length(x), 4);
    for i = 1:length(x)
        [ub, lb, ind] = find_gt(a, i);
        d = (i - lb)/ (ub - lb);
        ls(i,:) = [ub,  lb, ind, d];
    end
end