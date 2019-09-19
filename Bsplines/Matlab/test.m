addpath('optimisation');
addpath('mapping');

%parpool('local',16)

ptc = pcread('pc_9.ply');
[V, score] = pca(ptc.Location);
eps = 1e-3;
centroid = [mean(ptc.Location(:,1)), mean(ptc.Location(:,2)), mean(ptc.Location(:,3))];
v1 = V(:,1);
v2 = V(:,2);
d = dot(centroid, V(:,3));
plane = [V(:,3); d];

xgrid = dlmread('../Final/quadratic/xgrid_9.csv');
ygrid = dlmread('../Final/quadratic/ygrid_9.csv');
% xgrid(end) = xgrid(end) + eps;
% ygrid(end) = ygrid(end) + eps;

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
% hold on
% pcshow(score, ptc.Color)
% 
% [RMSE, SSE] = LinError(d, score, xgrid, ygrid, phi);

nCameras = 2;
camSequence = [1, 2];
CPfilename = '../Final/camparams/take3_OPTIMISED-PARAMETERS.h5';
img = imread('../Final/camparams/L.bmp');
img2 = imread('../Final/camparams/R.bmp');

[IntrinsicMatrix, LensDiostortionParams, RotationMatrix, TranslationMatrix] = get_camparams(nCameras, camSequence, CPfilename);
[tex,points] = projection(img, plane, v1, v2, centroid, ...
    IntrinsicMatrix{1}(1,1),  IntrinsicMatrix{1}(1,3), IntrinsicMatrix{1}(2,3), IntrinsicMatrix{1}(1,1)/ IntrinsicMatrix{1}(2,2));

[texp, ntex] = first_crop(points, tex, xgrid, ygrid, xyrange);




% pcshow(score)
% hold on 
% pcshow([texp, zeros(length(texp),1)], ntex)
