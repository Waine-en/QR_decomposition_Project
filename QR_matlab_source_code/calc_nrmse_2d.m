function nrmse = calc_nrmse_2d(y, x)
%CALC_NRMSE_2D Compute NRMSE between two complex 2D matrices.
%   nrmse = sqrt( sum(|y - x|^2) / sum(|x|^2) )

    % ---- checks ----
    if ~isequal(size(y), size(x))
        error('Input matrices y and x must have the same size.');
    end

    denom = sum(abs(x(:)).^2);
    if denom == 0
        error('Denominator is zero: sum(|x|^2) = 0. NRMSE is undefined.');
    end

    num = sum(abs(y(:) - x(:)).^2);

    nrmse = sqrt(num / denom);
end