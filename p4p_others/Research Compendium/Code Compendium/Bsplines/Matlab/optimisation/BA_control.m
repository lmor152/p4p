function [Phi] = BA_control(d, points, xgrid, ygrid)

%     evaluate control lattice (linear fit to points)
%     
%     Arguments:
%         d {int} -- degree of basis
%         points {matrix} -- points from pointcloud used to fit surface
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%     
%     Returns:
%         matrix -- (u+d-1) by (v+d-1) control grid (model parameters)
%     
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get min x,y coordinate in points
    minM = min(points(:,1));
    minN = min(points(:,2));
    
    % get number of control points in x,y direction
    u = length(xgrid);
    v = length(ygrid);
    
    % initialise delta, omega, and Phi
    delta = zeros(u+d-1, v+d-1);
    omg = zeros(u+d-1, v+d-1);
    Phi = zeros(u+d-1, v+d-1);
    
    % for each point in points
    for p = 1:length(points)
        
        % get the min, max, index of ensemble that corresponds to the point
        [exmax, exmin, i] = find_gt(xgrid, points(p,1) - minM);
        [eymax, eymin, j] = find_gt(ygrid, points(p,2) - minN);
        % get local coordinate of point (scaled between 0,1)
        s = (points(p,1) - minM - exmin)/ (exmax - exmin);
        t = (points(p,2) - minN - eymin)/ (eymax - eymin);
        % evaluate sum(w^2)
        sumWab2 = sumW2(d, s, t);
        % sum effect of point over support of basis
        for k = 0:d
            for l = 0:d
                % evaluate w
                w_kl = W(d, k, l, s, t);
                % evaluate phi
                Phi_kl = w_kl * points(p,3)/sumWab2;
                % calculate delta and omega kl
                delta(i+k, j+l) = delta(i+k, j+l) + Phi_kl * w_kl^2;
                omg(i+k, j+l) = omg(i+k,j+l) + w_kl^2;
            end
        end
    end
    % coordinate effect of points on control points in least squares way 
    for i = 1:(u+d-1)
        for j = 1:(v+d-1)
            if omg(i,j) ~= 0
                Phi(i,j) = delta(i,j)/omg(i,j);
            end
        end
    end
end