function [obj] = mapping_obj(Phi, refL, refR, IntrinsicMatrix, RotationMatrix, TranslationMatrix,  plane, V, centroid, xgrid, ygrid, xyrange, d)
    Phi = reshape(Phi, length(xgrid)+d-1, length(ygrid)+d-1);
    [world_coord,ntex] = BackWardProjection(refL, plane, V, centroid, IntrinsicMatrix{1}, [0,0,0], ...
    [0,0,0], xgrid, ygrid, xyrange, Phi, d);
    ssR = ForwardProject(refR, RotationMatrix{2}, IntrinsicMatrix{1}, TranslationMatrix{2}, world_coord, ntex);
    [world_coord1,ntex1] = BackWardProjection(refR, plane, V, centroid, IntrinsicMatrix{2}, RotationMatrix{2}, ...
    TranslationMatrix{2}, xgrid, ygrid, xyrange, Phi, d);
    ssL = ForwardProject(refL, [0,0,0], IntrinsicMatrix{2}, [0,0,0], world_coord1, ntex1);
    obj = -(ssR + ssL)/2;
end

