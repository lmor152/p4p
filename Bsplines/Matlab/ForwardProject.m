function [ss, IMG] = ForwardProject(ref, R, fx, T, world_coord, ntex)
    rotationMatrix = rotationVectorToMatrix(R);
    fmatrix = fx * [eye(3), zeros(3,1)] * [rotationMatrix, T'; zeros(1,3), 1];
    ptc1 = [world_coord, ones(length(world_coord),1)];
    img = fmatrix * ptc1';
    image = img(1:2,:) ./ img(3,:);
    asp = (fx(1,1)/fx(2,2));
    image(2,:) = image(2,:)/ asp;
    
    nonuniform = image';
    xmin = floor(min(nonuniform(:,1)));
    xmax = floor(max(nonuniform(:,1)));
    ymin = floor(min(nonuniform(:,2)));
    ymax = floor(max(nonuniform(:,2)));

    [A, B] = meshgrid(xmin:xmax, ymin:ymax);
    Y = [A(:), B(:)];
    [Indx, D] = knnsearch(nonuniform, Y, 'K',5);

    newtext = zeros(length(ntex),1);
    IMG = zeros(length(ymin:ymax), length(xmin:xmax));

    for i = 1:length(Indx)
        newtext(i) =  D(i,:) * ntex(Indx(i,:),1)/sum(D(i,:));
        IMG(Y(i,2) - ymin + 1, Y(i,1) - xmin + 1) = newtext(i)*255;
    end
    IMG = uint8(IMG);
    ss = ssim(IMG, ref(ymin:ymax, xmin:xmax));
end

