addpath('../')
%% perform PCA on different expressions
% read in neutral face
ptc = pcread('alignPTC/pca1.ply');
% transform points to PCAP coordinate system
[~, pp] = pca(ptc.Location);
% set up parameters
xmin = min(pp(:,1));
ymin = min(pp(:,2));
xyrange = [xmin, ymin];
d = 2;
xgrid = dlmread('alignPTC/xgrid.csv');
ygrid = dlmread('alignPTC/ygrid.csv');
% read in NL optimised control grid
phi1 = dlmread('Phi_NL_pca1.csv');
phi2 = dlmread('Phi_NL_pca2.csv');
phi3 = dlmread('Phi_NL_pca3.csv');
phi4 = dlmread('Phi_NL_pca4.csv');
phi5 = dlmread('Phi_NL_pca5.csv');

% create z matrix
z = [phi1(:), phi2(:), phi3(:), phi4(:), phi5(:)].';
% get centroid of z matrix
centroid = repmat(mean(z),1,numel(phi1));
% perform PCA
[V, score, latent, ~, explained] = pca(z);

% reshape result from PCA
newphi1 = reshape(V(:,1), size(phi1));
newphi2 = reshape(V(:,2), size(phi1));
newphi3 = reshape(V(:,3), size(phi1));
newphi4 = reshape(V(:,4), size(phi1));

%% Create mask
[X, Y] = meshgrid(ceil(min(pp(:,1))):1:floor(max(pp(:,1))), ...
    ceil(min(pp(:,2))):1:floor(max(pp(:,2))));
Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, reshape(mean(z), size(phi1)));
imagesc(Z')
mask = roipoly;
close all
%% Animate PCA effect
%mask = mask';
% init parameters
step = 1;
ind = 1;
% init X,Y grid
[X, Y] = meshgrid(ceil(min(pp(:,1))):1:floor(max(pp(:,1))), ...
    ceil(min(pp(:,2))):1:floor(max(pp(:,2))));
X(mask==0) = nan;
Y(mask==0) = nan;

% create figure
h = figure;

filename = 'testAnimated.gif';

for n = [0:step:2, 2-step:-step:-2, -2+step:step:-step]
    pppp = n*explained(1) * newphi1 + reshape(mean(z), size(phi1));
    Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, pppp);
    Z(mask==0) = nan;
    s = surf(X,Y,Z, 'FaceColor', 'c');
    daspect([1 1 1])
    set(gca, 'Zdir', 'reverse')
    %set(gca, 'color', 'none')
    set(gcf, 'color', [1 1 1])
    set(gca, 'color', [1 1 1])
    view(az,el)
    xlim([-88 92])
    ylim([-58 66])
    zlim([-35 20])
    drawnow 
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if ind == 1 
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
      imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    ind = ind+1;
 end
%% Animate optimisation

step = 1;
ind = 1;
[X, Y] = meshgrid(ceil(min(pp(:,1))):1:floor(max(pp(:,1))), ...
    ceil(min(pp(:,2))):1:floor(max(pp(:,2))));
% X(mask==0) = nan;
% Y(mask==0) = nan;

NLPhiFile = 'Phi_NL_pca1.csv';
LPhiFile = 'forPCA/Phi_pca1.csv';
NLPhi = dlmread(NLPhiFile);
LPhi = dlmread(LPhiFile);

h = figure;
filename = 'NLL2.gif';
for n = 1:5
    pppp = LPhi + n*(NLPhi - LPhi)/5;
    Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, pppp);
    s = surf(X,Y,Z, 'FaceColor', 'c');
    daspect([1 1 1])
    set(gca, 'Zdir', 'reverse')
    set(gca, 'color', 'w')
    set(gcf, 'color', 'w')
    view(70,55)
    xlim([-90 95])
    ylim([-60 70])
    zlim([-35 35])
    grid off
    axis off
    drawnow 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    if ind == 1 
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
      imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    ind = ind+1;
end

%% Plot quiver
% % create grid 
% [X, Y] = meshgrid(ceil(min(pp(:,1))):1:floor(max(pp(:,1))), ...
%     ceil(min(pp(:,2))):1:floor(max(pp(:,2))));
% 
% figure
% [u,v] = evaluateSurface_grad(d,X,Y,xgrid, ygrid, xyrange, newphi1);
% quiver(X,Y,u,v,10); axis image
% hold on
% hax = gca;
% Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, reshape(mean(z), size(phi1)));
% imagesc(hax.XLim,hax.YLim,Z)
% hold on
% quiver(X,Y,u,v,10, 'color', 'b')
% s = surf(X,Y,Z);
