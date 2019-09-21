function [x,y,z] = get_coord(img_point, F, t, T)
x = (img_point(1) - T(1))*t + T(1);
y = (img_point(2) - T(2))*t + T(2);
z = (F - T(3))*t + T(3);
end