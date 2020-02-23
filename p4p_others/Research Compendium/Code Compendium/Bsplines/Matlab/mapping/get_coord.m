function [x,y,z] = get_coord(img_point, F, t, T)
%     transform x,y,z 
%     
%     Arguments:
%         img_point {array} -- (x,y,z) 
%         F {float} -- focal length
%         t {float} -- line/ray length
%         T {floate} -- Translation vector
% 
%     Returns:
%         float -- evaluate basis at the local coordinates using the kth basis
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get transformed x,y,z
    x = (img_point(1) - T(1))*t + T(1);
    y = (img_point(2) - T(2))*t + T(2);
    z = (F - T(3))*t + T(3);
end