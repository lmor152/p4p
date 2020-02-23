function [tex,points] = projection(img, plane, v1, v2, centroid, F, cx, cy, asp, R, T)
%     Project image onto PCAP
%     
%     Arguments:
%         img {matrix} -- Grayscale image
%         plane {array} -- PCAP equation with coeff stored in array
%         v1 {array} -- First principle vector that defines PCAP
%         v2 {array} -- Second principle vector that defines PCAP
%         centroid {array} -- Centroid of PCAP plane
%         F {float} -- Focal length
%         cx {float} -- Back principle point x-direction in pixels
%         cy {float} -- Back principle point y-direction in pixels
%         asp {float} -- aspect ratio pixel size (fx/fy)
%         R {matrix} -- Rotation matrix
%         T {array} -- Translation vector
%
%     Returns:
%         array -- texture 
%         points -- projected texture to PCAP (in world coordinates)
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get size of image
    imsize = size(img);
    % initialise array to store texture values
    tex = zeros(imsize(1)*imsize(2),1);
    % initialise array to store projected points
    points = zeros(imsize(1)*imsize(2),2);
    % initialise count
    count = 1;
    
    % for every pixel in image
    for i = 1:imsize(2)
        for j = 1:imsize(1)
            % get image plane coordinates
            img_point = [i-1-cx, (j-1-cy) * asp];
            % apply rotation and translation to point
            img_point = (R * [img_point,F]' -T')';
            % project line onto plane
            t = line_projection(plane, img_point, F, -T);
            % store pixel texture
            tex(count) = img(j,i);
            % get coordiantes of project
            [x,y,z] = get_coord(img_point, F, t, -T);
            % get local coordinates of projection
            [x, y] = getLocal([x,y,z], v1, v2, centroid);
            % store point
            points(count,:) = [x, y];
            % update count
            count = count + 1;
        end
    end
end

