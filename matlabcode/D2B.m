overlap = 22;
fov = deg2rad(56.15/2);
d = 30;

x0 = 2*d*tan(fov);
x1 = x0/2 - overlap;

phi1 = atan((x1 + overlap/2)/d); 

B = 2*tan(phi1)*d