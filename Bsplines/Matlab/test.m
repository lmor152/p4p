ptc = pcread('pc_9.ply');
[coef, score] = pca(ptc.Location);
eps = 1e-3;

xgrid = dlmread('../Final/quadratic/xgrid_9.csv');
ygrid = dlmread('../Final/quadratic/ygrid_9.csv');
xgrid(end) = xgrid(end) + eps;
ygrid(end) = ygrid(end) + eps;

xmin = min(score(:,1));
ymin = min(score(:,2));
xyrange = [xmin, ymin];

d = 3;
Phi = BA_control(d, score, xgrid, ygrid);

global est
est = score(:,1:2);
E = error_obj(score, xgrid, ygrid, xyrange, Phi, d);


% [X, Y] = meshgrid(ceil(min(score(:,1))):floor(max(score(:,1))), ...
%     ceil(min(score(:,2))):floor(max(score(:,2))));
% 
% Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, Phi);

