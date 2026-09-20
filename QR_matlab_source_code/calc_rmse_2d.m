function rmse = calc_rmse_2d(y, x)
%CALC_RMSE_2D Compute RMSE between two complex 2D matrices.
%   rmse = sqrt( sum(|y - x|^2) / N )

    % ---- checks ----
    if ~isequal(size(y), size(x))
        error('Input matrices y and x must have the same size.');
    end

    num = sum(abs(y(:) - x(:)).^2);

    N = numel(x);

    rmse = sqrt(num / N);
end