addpath('../optimisation');
addpath('../mapping');
addpath('..')


eps = 1e-3;
ptcname = 'pca1';
ptc = pcread(strcat('alignPTC/',ptcname,'.ply'));
[V, score] = pca(ptc.Location);
score = double(score);
centroid = [mean(ptc.Location(:,1)), mean(ptc.Location(:,2)), mean(ptc.Location(:,3))];
v1 = V(:,1);
v2 = V(:,2);
d = dot(centroid, V(:,3));
plane = [V(:,3); d];

xgrid = dlmread('alignPTC/xgrid.csv');
ygrid = dlmread('alignPTC/ygrid.csv');
xgrid(end) = xgrid(end) + eps;
ygrid(end) = ygrid(end) + eps;

PhiFile = strcat('Phi_', ptcname, '.csv');

xmin = min(score(:,1));
ymin = min(score(:,2));
xyrange = [xmin, ymin];

d = 2;
Phi = BA_control(d, score, xgrid, ygrid);
dlmwrite(PhiFile, Phi)

