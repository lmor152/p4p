function [t] = line_projection(plane, img_point, F, T)
%     find intersection of ray (origin to img_point) with PCAP
%     
%     Arguments:
%         plane {array} -- PCAP coeff
%         img_point {array} -- image plane point 
%         F {float} -- Focal length
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x and y of point cloud
%         Phi {matrix} -- control lattice (model parameters) 
%     
%     Returns:
%         matrix -- predictions
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com  

    % find line plane intersection
    t = (plane(4) - T(1)*plane(1) - T(2)*plane(2) - T(3)*plane(3))/(plane(1)*(img_point(1) - T(1)) + plane(2)*(img_point(2)-T(2)) + plane(3)*(F-T(3)));
end