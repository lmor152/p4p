%from rectified to undistorted
function [out1, out2] = Rectified2Undistorted(Ix, Iy, d, stereoParams)

    points1 = [Ix,Iy];
    points2 = points1;
    points2(:,1) = points2(:,1) - d;


    sp = stereoParams.toStruct();
    H1 = projective2d(sp.RectificationParams.H1);
    H2 = projective2d(sp.RectificationParams.H2);

    origin = [sp.RectificationParams.XBounds(1), sp.RectificationParams.YBounds(1)];
    out1 = H1.transformPointsInverse(points1 + repmat(origin, [size(points1,1) 1]));
    out2 = H2.transformPointsInverse(points2 + repmat(origin, [size(points2,1) 1]));
    
end