%% Initialise settings

% add folders to path
addpath('optimisation');
addpath('mapping');

% read in point cloud
pointclound = 'forPCA/alignPTC/pca1.ply';
ptc = pcread(pointclound);

% find centroid of pointcloud
centroid = [mean(ptc.Location(:,1)), mean(ptc.Location(:,2)), mean(ptc.Location(:,3))];

% perform PCA on ptc to get PCAP plane and transformed poitns
[V, score] = pca(ptc.Location);
% makes poitns double
score = double(score);

% get first two principle vectors
v1 = V(:,1);
v2 = V(:,2);
% get d for PCAP plane equation
d = dot(centroid, V(:,3));
% get PCAP plane
plane = [V(:,3); d];

% set eps
eps = 1e-3;

% get xgrid and ygrid defined by python script
xgrid = dlmread('forPCA/alignPTC/xgrid.csv');
ygrid = dlmread('forPCA/alignPTC/ygrid.csv');
% add eps
xgrid(end) = xgrid(end) + 1e-3;
ygrid(end) = ygrid(end) + 1e-3;

% define file to read/write control grid to
PhiFile = 'forPCA/Phi_NL_pca1.csv';

% get xyrange
xmin = min(score(:,1));
ymin = min(score(:,2));
xyrange = [xmin, ymin];

%% Linear fit surface
% Linear fit bi-quadratic surface to pointcloud
d = 2;
Phi = BA_control(d, score, xgrid, ygrid);
%%
% initialise global varaible
global guess
guess = score(:,1:2);
% get linear-fit fitting errors
[E,~,~] = error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d);
% nonlinear optimisation     
[x,~] = NonLinear_opt(Phi, guess, score, xgrid, ygrid, xyrange, d, 100, 1e-6);
% write control grid to file
dlmwrite(PhiFile, reshape(x, length(xgrid)+d-1, length(ygrid)+d-1))

%% start texture stuff

% get control grid from file
Phi = dlmread(PhiFile);

% initialise settings to access camera parameters
nCameras = 2;
camSequence = [1, 2];
CPfilename = '../Final/camparams/take3_OPTIMISED-PARAMETERS.h5';
refL = imread('../Final/camparams/L.bmp');
refR = imread('../Final/camparams/R.bmp');
% get camera parameters from .h5 file
[IntrinsicMatrix, LensDiostortionParams, RotationMatrix, TranslationMatrix] = get_camparams(nCameras, camSequence, CPfilename);

% perform back projection Left-to-Rigth
[world_coord,ntex] = BackWardProjection(refL, plane, V, centroid, IntrinsicMatrix{1}, [0,0,0], ...
    [0,0,0], xgrid, ygrid, xyrange, Phi, d);
% forward projection Left-to-Rigth
[ssR, L2R, referenceR] = ForwardProject(refR, RotationMatrix{2}, IntrinsicMatrix{1}, TranslationMatrix{2}, world_coord, ntex);

% show figures
figure;
imshow(L2R);
figure;
imshow(referenceR)

% back project Right-to-Left
[world_coord,ntex] = BackWardProjection(refR, plane, V, centroid, IntrinsicMatrix{2}, RotationMatrix{2}, ...
    TranslationMatrix{2}, xgrid, ygrid, xyrange, Phi, d);
% forward project Right-to-Left
[ssL, R2L, referenceL] = ForwardProject(refL, [0,0,0], IntrinsicMatrix{2}, [0,0,0], world_coord, ntex);

% show figures
figure;
imshow(R2L);
figure;
imshow(referenceL)

%% build optimisation

% try update model parameters using texture
[x,F] = mapping_opt(Phi, refL, refR, newL, newR, IntrinsicMatrix, RotationMatrix, TranslationMatrix,plane, V, centroid, xgrid, ygrid, xyrange, d, 10);

%% Plotting surface
 
[X, Y] = meshgrid(ceil(min(score(:,1))):floor(max(score(:,1))), ...
    ceil(min(score(:,2))):floor(max(score(:,2))));

Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, Phi);
% s = surf(X,Y,Z, 'FaceColor', 'c', 'FaceAlpha', 0.2);
% daspect([1 1 1])
% set(gca, 'Zdir', 'reverse')
% hold on
% pcshow(score, ptc.Color)
 
% % Get linear fitting errors
%[RMSE, SSE, error] = LinError(d, score, xgrid, ygrid, phi);
