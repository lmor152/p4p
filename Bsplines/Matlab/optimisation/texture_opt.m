function [newX] = texture_opt(Phi, est, origin, impoint, xgrid, ygrid, xyrange, d)
    
    newX = zeros(size(est(:,1:2)));
    errors = zeros(length(est),1);
    
    options = optimoptions('fminunc','Algorithm','quasi-newton', 'SpecifyObjectiveGradient', true, 'display', 'iter');
    parfor i = 1:length(est)
        [x,F] = fminunc(@(x)texture_obj(x, origin, impoint(i,:), xgrid, ygrid, xyrange, Phi, d), est(i,:), options);
        newX(i,:) = x;
        errors(i) = F;
    end
end

