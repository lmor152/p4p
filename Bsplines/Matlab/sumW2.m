function [w2] = sumW2(d,s,t)
    w2 = 0;
    for i = 1:d
        for j = 1:d
            del = W(d, i, j, s, t);
            w2 = w2 + del;
        end
    end
end