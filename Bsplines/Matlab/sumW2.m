function [w2] = sumW2(d,s,t)
    w2 = 0;
    for i = 0:d
        for j = 0:d
            del = W(d, i, j, s, t)^2;
            w2 = w2 + del;
        end
    end
end