function [out] = ddBasis(d,k,t)

%     Evaluates Basis derivative
%     
%     Arguments:
%         d {[2,3]} -- degree of basis (2 or 3)
%         k {int} -- the basis function to be evaluated (>= 0 and <= 3)
%         t {float} -- local coordinate of point
% 
%     Returns:
%         float -- evaluate second derivative of basis at the local coordinates using the kth basis
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

%   check d, t, k are valid inputs
    assert(d == 2 | d ==3)
    assert(0 <= t & t <1)
    assert(k <= 3)
    
%   define basis based on order
%   quadratic basis 
    if d == 2
        if k == 0
            out = 1; 
        elseif k ==1
            out = -2;
        elseif k ==2
            out = 1;
        end
%   cubic basis        
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
