fx = dlmread('IntrincsicCam1.csv');
Rcam2 = dlmread('RotationCam2.csv');
Tcam2 = dlmread('Translation2.csv');
rotationMatrix = rotationVectorToMatrix(Rcam2);
fmatrix = fx * [eye(3), zeros(3,1)] * [rotationMatrix, Tcam2'; zeros(1,3), 1];

ptc = dlmread('../forehead/texturesurf.csv');
text = dlmread('../forehead/cleantex.csv');
figure;
pcshow(ptc, repmat(text,1,3))
fx = dlmread('IntrincsicCam1.csv');

ptc1 = [ptc, ones(length(ptc),1)];
img = fmatrix * ptc1';
image = img(1:2,:) ./ img(3,:);
image(2,:) = image(2,:)/ (fx(1,1)/fx(2,2));
%spot on
pcshow([image', zeros(length(image),1)], repmat(text,1,3))

nonuniform = image';
xmin = floor(min(nonuniform(:,1)));
xmax = floor(max(nonuniform(:,1)));
ymin = floor(min(nonuniform(:,2)));
ymax = floor(max(nonuniform(:,2)));

[A, B] = meshgrid(xmin:xmax, ymin:ymax);
Y = [A(:), B(:)];
[Indx, D] = knnsearch(nonuniform, Y, 'K',5);

newtext = zeros(length(text),1);
for i = 1:length(Indx)
    newtext(i) =  D(i,:) * text(Indx(i,:))/sum(D(i,:));
end

pcshow([Y, zeros(length(Y),1)],repmat(newtext,1,3)/255)

IMG = zeros(length(ymin:ymax), length(xmin:xmax));
for i = 1:length(Y)
    IMG(Y(i,2) - ymin + 1, Y(i,1) - xmin + 1) = newtext(i);  
end

IMG = uint8(IMG);
R = imread('R.bmp');
ssim(IMG, R(ymin:ymax, xmin:xmax))


