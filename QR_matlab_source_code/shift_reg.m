function [reg_after, shifted_out] = shift_reg(reg_now, data_in, direction)
%SHIFT_REG  模擬一個 1-bit shift register
%
% [reg_before, reg_after, shifted_out] = shift_reg(reg_now, data_in, direction)
%
% 輸入:
%   reg_now   : 目前暫存器內容 (1xN 向量，左邊為 MSB，右邊為 LSB)
%   data_in   : 這一拍要 shift 進去的資料 (scalar)
%   direction : 'left' 或 'right'
%               'left'  表示往左移，data_in 由右邊灌入
%               'right' 表示往右移，data_in 由左邊灌入
%
% 輸出:
%   reg_before : 位移前的暫存器內容
%   reg_after  : 位移後的暫存器內容
%   shifted_out: 被 shift 出去的那一個元素

    % 紀錄位移前
    reg_before = reg_now;

    switch lower(direction)
        case 'left'
            % 左移：最左邊被 shift out，新資料從右邊進來
            shifted_out = reg_now(1);
            reg_after   = [reg_now(2:end), data_in];

        case 'right'
            % 右移：最右邊被 shift out，新資料從左邊進來
            shifted_out = reg_now(end);
            reg_after   = [data_in, reg_now(1:end-1)];

        otherwise
            error('direction 必須是 ''left'' 或 ''right''');
    end
end