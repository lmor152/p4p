function [ls] = vfind(a, x)
%     vectorize find_gt
%     
%     Arguments:
%         a {array} -- the control grid in one direction
%         x {float} -- position of point in one direction
%     
%     Returns:
%         array -- [max, min, index] of ensemble
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com 

    % initialise empty array
    ls = zeros(length(x), 4);
    % for point in points
    for i = 1:length(x)
        % find max, min, and index of ensemble corresponding to point
        [ub, lb, ind] = find_gt(a, i);
        % scale point between (0,1)
        d = (i - lb)/ (ub - lb);
        % append to array
        ls(i,:) = [ub,  lb, ind, d];
    end
end