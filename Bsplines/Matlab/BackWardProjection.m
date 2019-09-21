function [world_coord,ntex] = BackWardProjection(ref, plane, V, centroid, fx, R, T, xgrid, ygrid, xyrange, Phi, d)
    rotationMatrix = rotationVectorToMatrix(R);
    [tex,points] = projection(ref, plane, V(:,1), V(:,2), centroid, ...
        fx(1,1),  fx(1,3), fx(2,3), fx(1,1)/ fx(2,2), rotationMatrix, T);

    [texp, ntex] = first_crop(points, tex, xgrid, ygrid, xyrange);

    origin = [dot(-T - centroid, V(:,1)), ...
            dot(-T - centroid, V(:,2)), ...
            dot(-T - centroid, V(:,3))];

    [newX] = texture_opt(Phi, texp, double(origin), texp, xgrid, ygrid, xyrange, d);
    [texp, ntex] = second_crop(newX, ntex, xgrid, ygrid, xyrange);
    texZ = evaluate_pointvec(d,texp(:,1),texp(:,2),xgrid, ygrid, xyrange, Phi);
    texpoints = [texp, texZ];
    [world_coord] = toWorld(texpoints, centroid, V);
    
end

