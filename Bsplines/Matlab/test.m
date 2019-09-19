addpath('optimisation');
addpath('mapping');

%parpool('local',16)

ptc = pcread('pc_9.ply');
[coef, score] = pca(ptc.Location);
eps = 1e-3;

xgrid = dlmread('../Final/quadratic/xgrid_20.csv');
ygrid = dlmread('../Final/quadratic/ygrid_20.csv');
xgrid(end) = xgrid(end) + eps;
ygrid(end) = ygrid(end) + eps;

xmin = min(score(:,1));
ymin = min(score(:,2));
xyrange = [xmin, ymin];

d = 2;
Phi = BA_control(d, score, xgrid, ygrid);

%options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'iter');
%[x,F,exitflag] = fminunc(@(x)euclidean_obj(x, score(2,:), xgrid, ygrid, xyrange, Phi, d), score(2,1:2), options)
global guess
guess = score(:,1:2);
E = error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d);
    
options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'off',...
     'CheckGradients', true, 'MaxIterations', 1);    
[x,F,exitflag] = fminunc(@(Phi)error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d), Phi, options);
% 
% [X, Y] = meshgrid(ceil(min(score(:,1))):floor(max(score(:,1))), ...
%     ceil(min(score(:,2))):floor(max(score(:,2))));
% 
% Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, Phi);
% s = surf(X,Y,Z);
% daspect([1 1 1])
% 
% [RMSE, SSE] = LinError(d, score, xgrid, ygrid, phi);