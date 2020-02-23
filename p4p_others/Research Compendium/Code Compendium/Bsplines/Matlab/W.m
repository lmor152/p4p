function [w] = W(d, k, l, s, t)
%   evaluate w
    w = Basis(d,k,s) * Basis(d,l,t);
end