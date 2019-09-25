addpath('../optimisation');
addpath('../mapping');
addpath('..')


eps = 1e-3;
ptcname = 'pca5';
ptcref = pcread(strcat('alignPTC/pca1.ply'));
ptc = pcread(strcat('alignPTC/',ptcname,'.ply'));
[V, score] = pca(ptcref.Location);
centroid = [mean(ptc.Location(:,1)), mean(ptc.Location(:,2)), mean(ptc.Location(:,3))];


points = zeros(size(score));
for i = 1:length(ptc.Location)
    [x, y, z] = pc_project(ptc.Location(i,:), V(:,1), V(:,2), V(:,3), centroid);
    points(i,:) = [x,y,z];
end

points = double(points);

xgrid = dlmread('alignPTC/xgrid.csv');
ygrid = dlmread('alignPTC/ygrid.csv');
xgrid(end) = xgrid(end) + eps;
ygrid(end) = ygrid(end) + eps;

PhiFile = strcat('Phi_', ptcname, '.csv');

xmin = min(points(:,1));
ymin = min(points(:,2));
xyrange = [xmin, ymin];

d = 2;
Phi = BA_control(d, points, xgrid, ygrid);
dlmwrite(PhiFile, Phi)
%%

% [X, Y] = meshgrid(ceil(min(score(:,1))):floor(max(score(:,1))), ...
%     ceil(min(score(:,2))):floor(max(score(:,2))));
% 
% Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, phi3);
% s = surf(X,Y,Z);
% daspect([1 1 1])

%%