ptc = dlmread('../forehead/texturesurf.csv');
text = dlmread('../forehead/cleantex.csv');
figure;
pcshow(ptc, repmat(text,1,3)/255)
fx = dlmread('IntrincsicCam1.csv');

fmatrix = [fx, zeros(3,1)];
ptc1 = [ptc, ones(length(ptc),1)];
img = fmatrix * ptc1';
image = img(1:2,:) ./ img(3,:);
image(:,2) = image(:,2)/ (fx(1,1)/fx(2,2));
%spot on
pcshow([image', zeros(length(image),1)], repmat(text,1,3))



