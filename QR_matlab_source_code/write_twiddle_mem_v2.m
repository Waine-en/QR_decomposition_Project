%function [hex_digits, qr, qi, qr_u, qi_u] = write_twiddle_mem_v2(ROM4, WL, FRAC)
%%WRITE_TWIDDLE_MEM  將複數 twiddle/ROM 量化成固定點並輸出成 Verilog 可讀的 .mem(hex)
%%
%%   [qr, qi, qr_u, qi_u] = write_twiddle_mem(ROM4, WL, FRAC, fname_r, fname_i)
%%
%% Inputs:
%%   ROM4    : 複數向量/矩陣（twiddle factor），例如 [W0; W1; ...]
%%   WL      : word length (bits)，例如 20
%%   FRAC    : fractional bits，例如 15 -> Q( WL-FRAC ).FRAC
%%   fname_r : 輸出 real 檔名，例如 'tw_r.mem'
%%   fname_i : 輸出 imag 檔名，例如 'tw_i.mem'
%%
%% Outputs:
%%   qr, qi  : 量化後 signed 整數（double / int64 值域）
%%   qr_u,qi_u: 對應 WL-bit two's complement 的 unsigned 表示（int64，0..2^WL-1）
%%
%% Notes:
%%   - 使用 round(x*2^FRAC)
%%   - 依 WL-bit signed 範圍飽和
%%   - 輸出每行固定 hex_digits 位（WL=20 -> 5）
%%   - 讀入 Verilog 端用 $readmemh + $signed() 即可
%
%    if nargin < 2 || isempty(WL),      WL = 20;   end
%    if nargin < 3 || isempty(FRAC),    FRAC = 15; end
% 
%
%
%    % 基本檢查
%    if ~isnumeric(ROM4)
%        error('ROM4 must be numeric (complex allowed).');
%    end
%    if WL <= 0 || FRAC < 0 || FRAC >= WL
%        error('Invalid WL/FRAC. Require WL>0, 0<=FRAC<WL.');
%    end
%
%    S = 2^FRAC;
%
%    wr = real(ROM4);
%    wi = imag(ROM4);
%
%    qr = floor(wr * S);
%    qi = floor(wi * S);
%
%    % 飽和到 WL-bit signed 範圍
%    maxv = 2^(WL-1) - 1;
%    minv = -2^(WL-1);
%    qr = min(max(qr, minv), maxv);
%    qi = min(max(qi, minv), maxv);
%
%    % 轉成 WL-bit two's complement 的 unsigned 表示
%    MOD = 2^WL;
%    qr_u = mod(int64(qr), MOD);
%    qi_u = mod(int64(qi), MOD);
%
%    hex_digits = ceil(WL/4);
%end


function [hex_digits, qr, qi, qr_u, qi_u] = write_twiddle_mem_v2(ROM4, WL, FRAC)
%WRITE_TWIDDLE_MEM  將複數 twiddle/ROM 量化成固定點並輸出成 Verilog 可讀的 .mem(hex)
%
%   [qr, qi, qr_u, qi_u] = write_twiddle_mem(ROM4, WL, FRAC, fname_r, fname_i)
%
% Inputs:
%   ROM4    : 複數向量/矩陣（twiddle factor），例如 [W0; W1; ...]
%   WL      : word length (bits)，例如 20
%   FRAC    : fractional bits，例如 15 -> Q( WL-FRAC ).FRAC
%   fname_r : 輸出 real 檔名，例如 'tw_r.mem'
%   fname_i : 輸出 imag 檔名，例如 'tw_i.mem'
%
% Outputs:
%   qr, qi  : 量化後 signed 整數（double / int64 值域）
%   qr_u,qi_u: 對應 WL-bit two's complement 的 unsigned 表示（int64，0..2^WL-1）
%
% Notes:
%   - 使用 floor(x*2^FRAC)
%   - 依 WL-bit signed 範圍飽和
%   - 輸出每行固定 hex_digits 位（WL=20 -> 5）
%   - 讀入 Verilog 端用 $readmemh + $signed() 即可

    if nargin < 2 || isempty(WL),      WL = 20;   end
    if nargin < 3 || isempty(FRAC),    FRAC = 15; end

    % 基本檢查
    if ~isnumeric(ROM4)
        error('ROM4 must be numeric (complex allowed).');
    end
    if WL <= 0 || FRAC < 0 || FRAC >= WL
        error('Invalid WL/FRAC. Require WL>0, 0<=FRAC<WL.');
    end

    S = int64(2^FRAC);

    wr = real(ROM4);
    wi = imag(ROM4);

    qr = int64(floor(wr * double(S)));
    qi = int64(floor(wi * double(S)));

    % 飽和到 WL-bit signed 範圍
    maxv = int64( 2^(WL-1) - 1 );
    minv = int64(-2^(WL-1)     );
    qr = min(max(qr, minv), maxv);
    qi = min(max(qi, minv), maxv);

    % 轉成 WL-bit two's complement 的 unsigned 表示
    MOD = int64(2^WL);
    qr_u = mod(qr, MOD);
    qi_u = mod(qi, MOD);

    % 若外部仍希望 qr, qi 是 double，就轉回 double
    qr = double(qr);
    qi = double(qi);

    hex_digits = ceil(WL/4);
end