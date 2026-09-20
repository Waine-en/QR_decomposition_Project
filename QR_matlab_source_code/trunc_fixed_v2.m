function x_trunc = trunc_fixed_v2(x, WL, FL, mode)
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

%% ===== local helper =====
%function x_trunc = trunc_fixed_real(x, WL, FL, mode)
%% works on real array x, elementwise
%
%    scale = 2^FL;
%
%    if mode == "round_to_zero"
%        % trunc toward 0: pos -> floor, neg -> ceil
%        N = floor(x * scale);
%        idx_neg = (x < 0);
%        N(idx_neg) = ceil(x(idx_neg) * scale);
%    else
%        % floor toward -inf
%        N = floor(x * scale);
%    end
%
%    % wrap to WL-bit two's complement (mod 2^WL)
%    MOD = 2^WL;
%    N_u = mod(N, MOD);                 % 0 .. 2^WL-1
%
%    % restore signed integer
%    idx = (N_u >= 2^(WL-1));
%    N_u(idx) = N_u(idx) - MOD;
%
%    x_trunc = double(N_u) / scale;
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ===== local helper =====
%function x_trunc = trunc_fixed_real(x, WL, FL, mode)
%% works on real array x, elementwise
%
%    if nargin < 4 || isempty(mode), mode = "floor"; end
%
%    scale = int64(2^FL);
%
%    % 先轉成整數碼
%    x_scaled = x * double(scale);
%
%    if mode == "toward_zero" || mode == "round_to_zero"
%        N = int64(floor(x_scaled));
%        idx_neg = (x < 0);
%        N(idx_neg) = int64(ceil(x_scaled(idx_neg)));
%
%%    if mode == "toward_zero" || mode == "round_to_zero"
%%        % trunc toward 0: pos -> floor, neg -> ceil
%%        N = floor(x * scale);
%%        idx_neg = (x < 0);
%%        N(idx_neg) = ceil(x(idx_neg) * scale);
%
%
%    else
%        N = int64(floor(x_scaled));
%    end
%
%    % 固定使用 saturate
%    MINV = int64(-2^(WL-1));
%    MAXV = int64( 2^(WL-1)-1);
%    N_sat = min(max(N, MINV), MAXV);
%
%    % 轉回 Q(WL,FL) 的 double 值
%    x_trunc = double(N_sat) / double(scale);
%end
%*/

function x_trunc = trunc_fixed_real(x, WL, FL, mode)
% Fixed-point quantization with two's-complement wrap-around

    if nargin < 4 || isempty(mode)
        mode = "floor";
    end

    scale = 2^FL;
    x_scaled = x * scale;

    % Quantization
    if mode == "toward_zero" || mode == "round_to_zero"
        N = floor(x_scaled);
        idx_neg = (x < 0);
        N(idx_neg) = ceil(x_scaled(idx_neg));
    else
        % arithmetic-shift-compatible
        N = floor(x_scaled);
    end

    % Two's-complement wrap-around
    MOD = 2^WL;

    N_u = mod(N, MOD);

    idx_neg = (N_u >= 2^(WL-1));
    N_u(idx_neg) = N_u(idx_neg) - MOD;

    % Back to fixed-point value
    x_trunc = N_u / scale;
end