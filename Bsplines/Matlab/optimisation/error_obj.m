function [E, jac] = error_obj(est, points, xgrid, ygrid, xyrange, Phi, d)

    newX = zeros(size(points(:,1:2)));
    errors = zeros(length(points),1);
    flags = zeros(length(points),1);

    options = optimoptions('fminunc','Algorithm','quasi-newton','SpecifyObjectiveGradient',true, 'display', 'off');
    parfor (i = 1:length(points),16)
        [x,F,exitflag] = fminunc(@(x)euclidean_obj(x, points(i,:), xgrid, ygrid, xyrange, Phi, d), est(i,:), options);
        newX(i,:) = x;
        errors(i) = F;
        flags(i) = exitflag;
    end

    if nargout > 1
        dPhi = field_jac(est, points, xgrid, ygrid, xyrange, Phi, d); 
        jac = dPhi(:);
    end
    
    E = sum(errors);
    global guess
    guess = newX;
    
end

