%from point cloud to rectified
function [Ix, Iy, d] = PC2Rectified(im3d, Q)

    a = Q(4,3);
    b = Q(4,4);
    f = Q(3,4);
    Cx = -Q(1,4);
    Cy = -Q(2,4);

    d = zeros(length(im3d),1);
    Ix = d;
    Iy = d;

    for i=1:length(im3d)

        d(i) = (f - im3d(i,3) * b ) / ( im3d(i,3) * a);

        Ix(i) = im3d(i,1) * ( d(i) * a + b ) + Cx;

        Iy(i) = im3d(i,2) * ( d(i) * a + b ) + Cy;    

    end
end





