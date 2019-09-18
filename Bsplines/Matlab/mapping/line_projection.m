function [t] = line_projection(plane, img_point, F)
t = plane(4)/(plane(1)*img_point(1) + plane(2)*img_point(2) + plane(3)*F);
end