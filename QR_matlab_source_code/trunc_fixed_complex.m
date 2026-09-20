function x_trunc = trunc_fixed_complex(x, WL, FL, mode)
%TRUNC_FIXED  Fixed-point trunc/quantize for real or complex input
%   x    : real/complex scalar, vector, or matrix
%   WL   : word length (incl. sign)
%   FL   : fractional length
%   mode : "round_to_zero" or other (default: floor toward -inf)

    if ~isreal(x)
        xr = trunc_fixed_real(real(x), WL, FL, mode);
        xi = trunc_fixed_real(imag(x), WL, FL, mode);
        x_trunc = complex(xr, xi);
    else
        x_trunc = trunc_fixed_real(x, WL, FL, mode);
    end
end

% ===== local helper =====
function x_trunc = trunc_fixed_real(x, WL, FL, mode)
% works on real array x, elementwise

    scale = 2^FL;

    if mode == "round_to_zero"
        % trunc toward 0: pos -> floor, neg -> ceil
        N = floor(x * scale);
        idx_neg = (x < 0);
        N(idx_neg) = ceil(x(idx_neg) * scale);
    else
        % floor toward -inf
        N = floor(x * scale);
    end

    % wrap to WL-bit two's complement (mod 2^WL)
    MOD = 2^WL;
    N_u = mod(N, MOD);                 % 0 .. 2^WL-1

    % restore signed integer
    idx = (N_u >= 2^(WL-1));
    N_u(idx) = N_u(idx) - MOD;

    x_trunc = double(N_u) / scale;
end