function [w] = W(d, k, l, s, t)
    w = Basis(d,k,s) * Basis(d,l,t);
end