function [ss, IMG, reference] = ForwardProject(ref, R, fx, T, world_coord, ntex)
%    project image to surface model 
%     
%     Arguments:
%         ref {matrix} -- image to project
%         R {array} -- Rotation vector
%         fx {float} -- Focal length
%         T {array} -- Translation vector
%         world_coord {matrix} -- world points
%         ntex {array} -- texture
%     
%     Returns:
%         float -- similarity score
%         matrix -- projected image
%         reference -- cropped reference image
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com  

    % get rotation matrix from vector
    rotationMatrix = rotationVectorToMatrix(R);
    % create projection matrix
    fmatrix = fx * [eye(3), zeros(3,1)] * [rotationMatrix, T'; zeros(1,3), 1];
    ptc1 = [world_coord, ones(length(world_coord),1)];
    % project image
    img = fmatrix * ptc1';
    image = img(1:2,:) ./ img(3,:);
    asp = (fx(1,1)/fx(2,2));
    image(2,:) = image(2,:)/ asp;
    
    % invert image
    nonuniform = image';
    % normalise projected image using knn
    xmin = floor(min(nonuniform(:,1)));
    xmax = floor(max(nonuniform(:,1)));
    ymin = floor(min(nonuniform(:,2)));
    ymax = floor(max(nonuniform(:,2)));
    [A, B] = meshgrid(xmin:xmax, ymin:ymax);
    Y = [A(:), B(:)];
    [Indx, D] = knnsearch(nonuniform, Y, 'K', 4);

    % initialise texture array
    newtext = zeros(length(ntex),1);
    IMG = zeros(length(ymin:ymax), length(xmin:xmax));

    % reshape image 
    for i = 1:length(Indx)
        newtext(i) =  D(i,:) * ntex(Indx(i,:),1)/sum(D(i,:));
        IMG(Y(i,2) - ymin + 1, Y(i,1) - xmin + 1) = newtext(i)*255;
    end
    % convert img
    IMG = uint8(IMG);
    reference = ref(ymin:ymax, xmin:xmax);

    % measure similarity score (can use a ssim, SSE, ..etc)
    %ss = ssim(IMG, reference);
    ss = sum(sum(imabsdiff(IMG, reference)));
end

