function [E, jac] = error_obj(points, xgrid, ygrid, xyrange, Phi, d)

    global est
    newX = zeros(size(points(:,1:2)));
    errors = zeros(length(points),1);
    flags = zeros(length(points),1);

    options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true, 'display', 'off');
    for i = 1:length(points)
        [x,F,exitflag] = fminunc(@(x)euclidean_obj(x, points(i,:), xgrid, ygrid, xyrange, Phi, d), est(i,1:2), options);
        newX(i,:) = x;
        errors(i) = F;
        flags(i) = exitflag;
    end
    E = sum(F);
    est = newX;
    
    if nargout > 1
        dPhi = field_jac(point, xgrid, ygrid, xyrange, Phi, d); 
        jac = dPhi;
    end
end

