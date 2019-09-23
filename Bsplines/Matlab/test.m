addpath('optimisation');
addpath('mapping');

%parpool('local',16)

ptc = pcread('../Final/forehead/forehead.ply');
[V, score] = pca(ptc.Location);
score = double(score);
eps = 1e-3;
centroid = [mean(ptc.Location(:,1)), mean(ptc.Location(:,2)), mean(ptc.Location(:,3))];
v1 = V(:,1);
v2 = V(:,2);
d = dot(centroid, V(:,3));
plane = [V(:,3); d];
% 
xgrid = dlmread('test4VM/xgrid_test4.csv');
ygrid = dlmread('test4VM/ygrid_test4.csv');
PhiFile = 'test4NLPhi.csv';

xgrid(end) = xgrid(end) + eps;
ygrid(end) = ygrid(end) + eps;

xmin = min(score(:,1));
ymin = min(score(:,2));
xyrange = [xmin, ymin];
%%
d = 2;
Phi = BA_control(d, score, xgrid, ygrid);

%options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'iter');
%[x,F,exitflag] = fminunc(@(x)euclidean_obj(x, score(2,:), xgrid, ygrid, xyrange, Phi, d), score(2,1:2), options)
global guess
guess = score(:,1:2);
% E = error_obj(guess, score, xgrid, ygrid, xyrange, Phi, d);
%     
[x,F] = NonLinear_opt(Phi, guess, score, xgrid, ygrid, xyrange, d, 100, 1e-6);
dlmwrite(PhiFile, reshape(x, length(xgrid)+d-1, length(ygrid)+d-1))

%% start texture stuff

%Phi = dlmread('../Final/forehead/Phi_5.csv');
Phi = dlmread(PhiFile);

nCameras = 2;
camSequence = [1, 2];
CPfilename = '../Final/camparams/take3_OPTIMISED-PARAMETERS.h5';
refL = imread('../Final/camparams/L.bmp');
refR = imread('../Final/camparams/R.bmp');
[IntrinsicMatrix, LensDiostortionParams, RotationMatrix, TranslationMatrix] = get_camparams(nCameras, camSequence, CPfilename);

[world_coord,ntex] = BackWardProjection(refL, plane, V, centroid, IntrinsicMatrix{1}, [0,0,0], ...
    [0,0,0], xgrid, ygrid, xyrange, Phi, d);
[ssR, L2R, referenceR] = ForwardProject(refR, RotationMatrix{2}, IntrinsicMatrix{1}, TranslationMatrix{2}, world_coord, ntex);

figure;
imshow(L2R);
figure;
imshow(referenceR)

[world_coord,ntex] = BackWardProjection(refR, plane, V, centroid, IntrinsicMatrix{2}, RotationMatrix{2}, ...
    TranslationMatrix{2}, xgrid, ygrid, xyrange, Phi, d);
[ssL, R2L, referenceL] = ForwardProject(refL, [0,0,0], IntrinsicMatrix{2}, [0,0,0], world_coord, ntex);

figure;
imshow(R2L);
figure;
imshow(referenceL)

%% build optimisation

[x,F] = mapping_opt(Phi, refL, refR, newL, newR, IntrinsicMatrix, RotationMatrix, TranslationMatrix,plane, V, centroid, xgrid, ygrid, xyrange, d, 10);


%%
[tex,points] = projection(refL, plane, v1, v2, centroid, ...
    IntrinsicMatrix{1}(1,1),  IntrinsicMatrix{1}(1,3), IntrinsicMatrix{1}(2,3), IntrinsicMatrix{1}(1,1)/ IntrinsicMatrix{1}(2,2),...
    eye(3), [0,0,0]);
% 
[texp, ntex] = first_crop(points, tex, xgrid, ygrid, xyrange);
% 
origin = [dot([0,0,0] - centroid, V(:,1)), ...
        dot([0,0,0] - centroid, V(:,2)), ...
        dot([0,0,0] - centroid, V(:,3))];
    
[newX] = texture_opt(Phi, texp, double(origin), texp, xgrid, ygrid, xyrange, d);
% [texp, ntex] = second_crop(newX, ntex, xgrid, ygrid, xyrange);
% texZ = evaluate_pointvec(d,texp(:,1),texp(:,2),xgrid, ygrid, xyrange, Phi);
% texpoints = [texp, texZ];
% [world_coord] = toWorld(texpoints, centroid, V);

% [world_coord,ntex] = BackWardProjection(refL, plane, V, centroid, IntrinsicMatrix{1}, [0,0,0], ...
%     [0,0,0], xgrid, ygrid, xyrange, Phi, d);
% 
% pcshow(world_coord, ntex)
% [ssR, L2R] = ForwardProject(refR, RotationMatrix{2}, IntrinsicMatrix{1}, TranslationMatrix{2}, world_coord, ntex);

% rotationMatrix = rotationVectorToMatrix(RotationMatrix{2});
% fmatrix = IntrinsicMatrix{1} * [eye(3), zeros(3,1)] * [rotationMatrix, TranslationMatrix{2}'; zeros(1,3), 1];
% ptc1 = [world_coord, ones(length(world_coord),1)];
% img = fmatrix * ptc1';
% image = img(1:2,:) ./ img(3,:);
% asp = (IntrinsicMatrix{1}(1,1)/IntrinsicMatrix{1}(2,2));
% image(2,:) = image(2,:)/ asp;
% 
% pcshow([image', zeros(length(image),1)], ntex)
% 
% nonuniform = image';
% xmin = floor(min(nonuniform(:,1)));
% xmax = floor(max(nonuniform(:,1)));
% ymin = floor(min(nonuniform(:,2)));
% ymax = floor(max(nonuniform(:,2)));
% 
% [A, B] = meshgrid(xmin:xmax, ymin:ymax);
% Y = [A(:), B(:)];
% [Indx, D] = knnsearch(nonuniform, Y, 'K',5);
% 
% newtext = zeros(length(ntex),1);
% for i = 1:length(Indx)
%     newtext(i) =  D(i,:) * ntex(Indx(i,:),1)/sum(D(i,:));
% end
% 
% pcshow([Y, zeros(length(Y),1)],repmat(newtext,1,3))
% 
% IMG = zeros(length(ymin:ymax), length(xmin:xmax));
% for i = 1:length(Y)
%     IMG(Y(i,2) - ymin + 1, Y(i,1) - xmin + 1) = newtext(i)*255;  
% end
% 
% IMG = uint8(IMG);
% ssim(IMG, refR(ymin:ymax, xmin:xmax))
% 
% 
% [world_coord,ntex] = BackWardProjection(refR, plane, V, centroid, IntrinsicMatrix{2}, rotationMatrix, ...
%     TranslationMatrix{2}, xgrid, ygrid, xyrange, Phi, d);

% [tex,points] = projection(refR, plane, v1, v2, centroid, ...
%     IntrinsicMatrix{2}(1,1),  IntrinsicMatrix{2}(1,3), IntrinsicMatrix{2}(2,3), IntrinsicMatrix{2}(1,1)/ IntrinsicMatrix{2}(2,2),...
%     rotationMatrix, TranslationMatrix{2});
% 
% [texp, ntex] = first_crop(points, tex, xgrid, ygrid, xyrange);
% 
% origin = [dot(-TranslationMatrix{2} - centroid, V(:,1)), ...
%         dot(-TranslationMatrix{2} - centroid, V(:,2)), ...
%         dot(-TranslationMatrix{2} - centroid, V(:,3))];
% 
% [newX] = texture_opt(Phi, texp, double(origin), texp, xgrid, ygrid, xyrange, d);
% [texp, ntex] = second_crop(newX, ntex, xgrid, ygrid, xyrange);
% texZ = evaluate_pointvec(d,texp(:,1),texp(:,2),xgrid, ygrid, xyrange, Phi);
% texpoints = [texp, texZ];
% [world_coord] = toWorld(texpoints, centroid, V);

% pcshow(world_coord, ntex)

% [world_coord,ntex] = BackWardProjection(refR, plane, V, centroid, IntrinsicMatrix{2}, RotationMatrix{2}, ...
%     TranslationMatrix{2}, xgrid, ygrid, xyrange, Phi, d);
% [ssL, R2L] = ForwardProject(refL, [0,0,0], IntrinsicMatrix{2}, [0,0,0], world_coord, ntex);
% % rotationMatrix = rotationVectorToMatrix(RotationMatrix{2});
% fmatrix = IntrinsicMatrix{2} * [eye(3), zeros(3,1)] * [rotationMatrix, [0,0,0]'; zeros(1,3), 1];
% ptc1 = [world_coord, ones(length(world_coord),1)];
% img = fmatrix * ptc1';
% image = img(1:2,:) ./ img(3,:);
% asp = (IntrinsicMatrix{2}(1,1)/IntrinsicMatrix{2}(2,2));
% image(2,:) = image(2,:)/ asp;
% 
% pcshow([image', zeros(length(image),1)], ntex)
% 
% nonuniform = image';
% xmin = floor(min(nonuniform(:,1)));
% xmax = floor(max(nonuniform(:,1)));
% ymin = floor(min(nonuniform(:,2)));
% ymax = floor(max(nonuniform(:,2)));
% 
% [A, B] = meshgrid(xmin:xmax, ymin:ymax);
% Y = [A(:), B(:)];
% [Indx, D] = knnsearch(nonuniform, Y, 'K',5);
% 
% newtext = zeros(length(ntex),1);
% IMG = zeros(length(ymin:ymax), length(xmin:xmax));
% 
% for i = 1:length(Indx)
%     newtext(i) =  D(i,:) * ntex(Indx(i,:),1)/sum(D(i,:));
%     IMG(Y(i,2) - ymin + 1, Y(i,1) - xmin + 1) = newtext(i)*255;
% end
% 
% pcshow([Y, zeros(length(Y),1)],repmat(newtext,1,3))
% 
% 
% 
% IMG = uint8(IMG);
% ssim(IMG, refL(ymin:ymax, xmin:xmax))

% pcshow(score)
% hold on 
% pcshow([texp, zeros(length(texp),1)], ntex)
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
