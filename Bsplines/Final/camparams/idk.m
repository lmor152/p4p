dir = "forehead";
mkdir(dir);
cloud = pcread('../forehead/pc_9.ply');
ptc = cloud.Location;
[V, score] = pca(ptc);
centroid = [mean(ptc(:,1)), mean(ptc(:,2)), mean(ptc(:,3))];
v1 = V(:,1);
v2 = V(:,2);
d = dot(centroid, V(:,3));
plane = [V(:,3); d];

fx = dlmread('IntrincsicCam1.csv');
F = fx(1,1);
cx = fx(1,3);
cy = fx(2,3);

img = imread('L.bmp');

imsize = size(img);
tex = zeros(imsize(1)*imsize(2),1);
p = zeros(imsize(1)*imsize(2),3);
points = zeros(imsize(1)*imsize(2),2);
count = 1;

for i = 1:imsize(2)
    for j = 1:imsize(1)
        img_point = [i-1-cx, (j-1-cy) * fx(1,1)/fx(2,2)];
        t = line_projection(plane, img_point, F);
        tex(count) = img(j,i);
        [x,y,z] = get_coord(img_point, F, t);
        p(count,:) = [x,y,z];
        [x, y] = getLocal([x,y,z], v1, v2, centroid);
        points(count,:) = [x, y];
        count = count + 1;
    end
end
% 
% pcshow(p, repmat(tex(:),1,3)/255)
% hold on
% pcshow(cloud)

pcshow(score)
hold on 
pcshow([points, zeros(length(points),1)], repmat(tex(:),1,3)/255)

xgrid = dlmread('../forehead/xgrid_95.csv');
ygrid = dlmread('../forehead/ygrid_95.csv');
xgrid = xgrid + min(score(:,1));
ygrid = ygrid + min(score(:,2));

xmin = min(xgrid);
xmax = max(xgrid);
ymin = min(ygrid);
ymax = max(ygrid);

xlogic = (points(:,1) >= xmin) & (points(:,1) <= xmax);
ylogic = (points(:,2) >= ymin) & (points(:,2) <= ymax);

texp = points(xlogic & ylogic, :);
ntex = repmat(tex(xlogic & ylogic),1,3)/255;

pcshow([texp, zeros(length(texp),1)], ntex)
hold on
pcshow(score)

%[x,y, texture/255]
dlmwrite(dir + "/texturemap",  [texp, ntex(:,1)])

function [t] = line_projection(plane, img_point, F)
t = plane(4)/(plane(1)*img_point(1) + plane(2)*img_point(2) + plane(3)*F);
end

function [x,y,z] = get_coord(img_point, F, t)
x = img_point(1)*t;
y = img_point(2)*t;
z = F*t;
end

function [x, y] = getLocal(world, v1, v2, centroid)
x = dot(world - centroid, v1);
y = dot(world - centroid, v2);
end



    