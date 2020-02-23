function [out] = Basis(d,k,t)
%     Evaluates Basis
%     
%     Arguments:
%         d {[2,3]} -- degree of basis (2 or 3)
%         k {int} -- the basis function to be evaluated (>= 0 and <= 3)
%         t {float} -- local coordinate of point
% 
%     Returns:
%         float -- evaluate basis at the local coordinates using the kth basis
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

%   check that b-spline order is 2 or 3 (quadratic or cubic)
    assert(d == 2 | d ==3)
%   check that local coordinate is between 0 and 1
    assert(0 <= t & t <1)  
    
%   define basis based on order
%   quadratic basis
    if d == 2
        if k == 0
            out = ((1-t)^2)/2; 
        elseif k ==1
            out = (2*t*(1-t) + 1)/2;
        elseif k ==2
            out = t^2/2;
        end
%   cubic basis
    elseif d == 3
        if k == 0
            out = ((1-t)^3) / 6;
        elseif k ==1
            out = (t * t * (3 * t - 6) + 4) / 6;
        elseif k ==2
            out = (t * (t * (-3 * t + 3) + 3) + 1) / 6;
        elseif k ==3
            out = (t^3) / 6;
        end 
    end
end
