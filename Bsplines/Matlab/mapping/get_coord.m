function [x,y,z] = get_coord(img_point, F, t)
x = img_point(1)*t;
y = img_point(2)*t;
z = F*t;
end