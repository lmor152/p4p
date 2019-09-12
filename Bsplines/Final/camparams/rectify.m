%do in python
% camImage = cell(2,1);
% 
% camImage{1} = imread(sprintf('%s/CAM%d/Image%d.bmp', imageDir,1,imNo));
% camImage{2} = imread(sprintf('%s/CAM%d/Image%d.bmp', imageDir,2,imNo));
% 
% camImage{1} = cv.undistort(camImage{1}, IntrinsicMatrix{1}, LensDiostortionParams{1});
% camImage{2} = cv.undistort(camImage{2}, IntrinsicMatrix{2}, LensDiostortionParams{2});
% 
% S = cv.stereoRectify(IntrinsicMatrix{1},LensDiostortionParams{1},IntrinsicMatrix{2},LensDiostortionParams{2},...
% size(camImage{1}), RotationMatrix{2}.', TranslationMatrix{2}.');

S.R2 = dlmread('S.R2');
S.Q = dlmread('S.Q');
IntrinsicMatrix{1} = dlmread('IntrincsicCam1.csv');
IntrinsicMatrix{2} = dlmread('IntrincsicCam2.csv');
TranslationMatrix{2} = dlmread('Translation2.csv');
camImage{1} = imread('Undistort1.png');
camImage{2} = imread('Undistort2.png');


cameraParams = cell(1,2);
cameraParams{1} = cameraParameters('IntrinsicMatrix',IntrinsicMatrix{1}');
cameraParams{2} = cameraParameters('IntrinsicMatrix',IntrinsicMatrix{2}');

stereoParams = stereoParameters(cameraParams{1},cameraParams{2},S.R2',TranslationMatrix{2}');

[rect1,rect2] = rectifyStereoImages(camImage{1}(:,:,1), camImage{2}(:,:,1), stereoParams,'OutputView','full');

im3d = dlmread('../quadratic/3dcontrolpoints.csv');
[Ix, Iy, d] = PC2Rectified(im3d, S.Q);

[out1, out2] = Rectified2Undistorted(Ix, Iy, d, stereoParams);

dlmwrite('out1.csv', out1)
dlmwrite('out2.csv', out2)

plot(cloud.Location(:,1), cloud.Location(:,2))


