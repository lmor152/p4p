% addpath('../optimisation');
% addpath('../mapping');
% addpath('..')
% 
% eps = 1e-3;
% 
% ptcref = pcread('alignPTC/pca1.ply');
% [V, score] = pca(ptcref.Location);
% score = double(score);
% centroid = [mean(ptcref.Location(:,1)), mean(ptcref.Location(:,2)), mean(ptcref.Location(:,3))];
% 
% xgrid = dlmread('alignPTC/xgrid.csv');
% ygrid = dlmread('alignPTC/ygrid.csv');
% xgrid(end) = xgrid(end) + eps;
% ygrid(end) = ygrid(end) + eps;
%     
% xmin = min(score(:,1));
% ymin = min(score(:,2));
% xyrange = [xmin, ymin];
% 
% d = 2;
% Phi = BA_control(d, score, xgrid, ygrid);
% dlmwrite('Phi_linear_1.csv', Phi)
% 
% global guess
% guess = score(:,1:2);
% 
% [x,F] = NonLinear_opt(Phi, guess, score, xgrid, ygrid, xyrange, d, 100, 1e-6);
% PhiFile = 'Phi_NL_pca1.csv';
% dlmwrite(PhiFile, reshape(x, length(xgrid)+d-1, length(ygrid)+d-1))

for i = 2:5 
    ptcname = strcat('pca',string(i));
    PhiFile = strcat('Phi_NL_', ptcname, '.csv');
    ptc = pcread(strcat('alignPTC/',ptcname,'.ply'));

    points = zeros(size(ptc.Location));
    for j = 1:length(ptc.Location)
        [x, y, z] = pc_project(ptc.Location(j,:), V(:,1), V(:,2), V(:,3), centroid);
        points(j,:) = [x,y,z];
    end
    
    xmin = min(points(:,1));
    ymin = min(points(:,2));
    xyrange = [xmin, ymin];   
    d = 2;
    Phi = BA_control(d, points, xgrid, ygrid);
    dlmwrite(strcat('Phi_L_', ptcname, '.csv'), Phi)
    guess = points(:,1:2);

    [x,F] = NonLinear_opt(Phi, guess, points, xgrid, ygrid, xyrange, d, 100, 1e-6);
    dlmwrite(PhiFile, reshape(x, length(xgrid)+d-1, length(ygrid)+d-1))
end



