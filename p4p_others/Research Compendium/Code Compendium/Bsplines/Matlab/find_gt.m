function [ub, lb, i] = find_gt(a, x)

%     find the position of point on the control grid
%     
%     Arguments:
%         a {array} -- the control grid in one direction
%         x {float} -- position of point in one direction
%     
%     Returns:
%         max -- the max coordinate of the ensemble
%         min -- the in coordinate of the ensemble
%         index -- the index of the ensemble
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com    

%   find where to inset element in array
    for i = 1:length(a)
        if x < a(i)
            i = i - 1;
            break
        end
    end
    
%   if x greater than last element in a
    if i == length(a)
        ub = 2*a(end) - a(end-1);
        lb = a(end);
%   if x less than first element in a
    elseif i < 1
        ub = a(1);
        lb = a(1) - a(2);
%   if x is within range of a
    else
        ub = a(i+1);
        lb = a(i);
    end
end