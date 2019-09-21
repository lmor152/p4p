function [t] = line_projection(plane, img_point, F, T)
t = (plane(4) - T(1)*plane(1) - T(2)*plane(2) - T(3)*plane(3))/(plane(1)*(img_point(1) - T(1)) + plane(2)*(img_point(2)-T(2)) + plane(3)*(F-T(3)));
end