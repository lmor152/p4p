function [tex,points] = projection(img, plane, v1, v2, centroid, F, cx, cy, asp, R, T)
    imsize = size(img);
    tex = zeros(imsize(1)*imsize(2),1);
    points = zeros(imsize(1)*imsize(2),2);
    count = 1;

    for i = 1:imsize(2)
        for j = 1:imsize(1)
            img_point = [i-1-cx, (j-1-cy) * asp];
            img_point = (R * [img_point,F]' -T')';
            t = line_projection(plane, img_point, F, -T);
            tex(count) = img(j,i);
            [x,y,z] = get_coord(img_point, F, t, -T);
            [x, y] = getLocal([x,y,z], v1, v2, centroid);
            points(count,:) = [x, y];
            count = count + 1;
        end
    end
end

