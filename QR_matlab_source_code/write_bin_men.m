function [theta_bin, theta_q] = write_bin_men(i, WL, FL, qmode)

    if nargin < 4 || isempty(qmode)
        qmode = 'round';
    end

    % ---- basic checks ----
   %validateattributes(i,  {'numeric'}, {'scalar','integer','nonnegative'});
    validateattributes(WL, {'numeric'}, {'scalar','integer','>=',2});
    validateattributes(FL, {'numeric'}, {'scalar','integer','>=',0,'<',WL});


    % ---- quantize to Q(WL-FL).FL ----
    S = 2^FL;
    x = i * S;

    switch lower(qmode)
        case 'round'
            theta_q = int64(round(x));
        case 'floor'
            theta_q = int64(floor(x));
        case 'ceil'
            theta_q = int64(ceil(x));
        case 'fix'
            theta_q = int64(fix(x));     % toward zero
        otherwise
            error('qmode must be one of: round/floor/ceil/fix');
    end

    % ---- saturate to WL-bit signed range ----
    maxv = int64(2^(WL-1) - 1);
    minv = int64(-2^(WL-1));
    theta_q = min(max(theta_q, minv), maxv);

    % ---- convert signed int -> WL-bit two''s complement binary string ----
    MOD = int64(2^WL);
    theta_u = mod(theta_q, MOD);               % 0..2^WL-1
    theta_bin = dec2bin(uint64(theta_u), WL);  % WL-bit string
end