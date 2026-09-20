%% ========================================================================
% QR Decomposition Fixed-point Sweep
% ========================================================================

clc;
clear;
close all;


%% ========================================================================
% Sweep 設定
% ========================================================================

% 20
WL_H_list       = 20:1:20;

% 19
WL_P_input_list = 19:1:19;

% 15
WL_S_list       = 15:1:15;

% 16
WL_PI_list      = 16:2:16;


%% ========================================================================
% Result Grid
%
% Dimension:
% NMSE_grid(WLH, WLP, WLS, WLPI)
% ========================================================================

NMSE_grid = zeros( ...
    numel(WL_H_list), ...
    numel(WL_P_input_list), ...
    numel(WL_S_list), ...
    numel(WL_PI_list));


%%
mode = 'trunc';
trunc_mode = 'trunc';
debug_mode = "true";


% 0. open file:
base_dir = "./result";
fname_in_A_r = fullfile(base_dir, "input_A_r.mem");
fname_in_A_i = fullfile(base_dir, "input_A_i.mem");
fname_in_B_r = fullfile(base_dir, "input_B_r.mem");
fname_in_B_i = fullfile(base_dir, "input_B_i.mem");
fname_in_C_r = fullfile(base_dir, "input_C_r.mem");
fname_in_C_i = fullfile(base_dir, "input_C_i.mem");
fname_in_D_r = fullfile(base_dir, "input_D_r.mem");
fname_in_D_i = fullfile(base_dir, "input_D_i.mem");
fname_out_A_r = fullfile(base_dir, "output_A_r.mem");
fname_out_A_i = fullfile(base_dir, "output_A_i.mem");
fname_out_B_r = fullfile(base_dir, "output_B_r.mem");
fname_out_B_i = fullfile(base_dir, "output_B_i.mem");
fname_out_C_r = fullfile(base_dir, "output_C_r.mem");
fname_out_C_i = fullfile(base_dir, "output_C_i.mem");
fname_out_D_r = fullfile(base_dir, "output_D_r.mem");
fname_out_D_i = fullfile(base_dir, "output_D_i.mem");

fid_in_A_r = fopen(fname_in_A_r, 'w');
fid_in_A_i = fopen(fname_in_A_i, 'w');
fid_in_B_r = fopen(fname_in_B_r, 'w');
fid_in_B_i = fopen(fname_in_B_i, 'w');
fid_in_C_r = fopen(fname_in_C_r, 'w');
fid_in_C_i = fopen(fname_in_C_i, 'w');
fid_in_D_r = fopen(fname_in_D_r, 'w');
fid_in_D_i = fopen(fname_in_D_i, 'w');
fid_out_A_r = fopen(fname_out_A_r, 'w');
fid_out_A_i = fopen(fname_out_A_i, 'w');
fid_out_B_r = fopen(fname_out_B_r, 'w');
fid_out_B_i = fopen(fname_out_B_i, 'w');
fid_out_C_r = fopen(fname_out_C_r, 'w');
fid_out_C_i = fopen(fname_out_C_i, 'w');
fid_out_D_r = fopen(fname_out_D_r, 'w');
fid_out_D_i = fopen(fname_out_D_i, 'w');
if (fid_in_A_r < 0) || (fid_in_A_i < 0) || (fid_in_B_r < 0) || (fid_in_B_i < 0) ||...
    (fid_in_C_r < 0) || (fid_in_C_i < 0) || (fid_in_D_r < 0) || (fid_in_D_i < 0) 
    error('Cannot open file for writing:');
end
if (fid_out_A_r < 0) || (fid_out_A_i < 0) || (fid_out_B_r < 0) || (fid_out_B_i < 0) ||...
    (fid_out_C_r < 0) || (fid_out_C_i < 0) || (fid_out_D_r < 0) || (fid_out_D_i < 0) 
    error('Cannot open file for writing:');
end


fname_PI = fullfile(base_dir, "PI.mem");
fname_THETA_E = fullfile(base_dir, "THETA_E.mem");
fname_S = fullfile(base_dir, "S.mem");
% --- PI ---
fid_PI = fopen(fname_PI, 'w');
if fid_PI < 0
    error('Cannot open file for writing: %s', fname_PI);
end
% --- THETA_E ---
fid_THETA_E = fopen(fname_THETA_E, 'w');
if fid_THETA_E < 0
    error('Cannot open file for writing: %s', fname_THETA_E);
end
% --- S ---
fid_S = fopen(fname_S, 'w');
if fid_S < 0
    error('Cannot open file for writing: %s', fname_S);
end



% QR分解(最新版):
    % 基本參數設定:
seed = 1234;
Iteration = 13;

first_cycle = 7;    % 最初的7個cycle
output_cycle = 8;    % 每8個cycle為一組資料
symbol_number = 1000;    % 要模擬多少個symbol
Cycle_number = first_cycle + (output_cycle * symbol_number);

PE_number = 7;
systolic_dim = 4;
input_len = output_cycle*symbol_number;


RQ_matrix = complex(zeros(systolic_dim, systolic_dim*2), zeros(systolic_dim, systolic_dim*2));
s_buf = zeros(symbol_number,1);
NRMSE_buf = zeros(symbol_number,2);




% ------------------------------------------------------------
% 4. Sweep
% ------------------------------------------------------------
fprintf('=============================================\n');
fprintf('Start Fixed-Point Sweep\n');
%fprintf('Total cases = %d\n', total_case);
fprintf('=============================================\n');


%QR_top(WL_H, FL_H, WL_P_input, FL_P_input, WL_S, FL_S, WL_PI, FL_PI, ...
%base_dir, mode, trunc_mode, debug_mode, ...
%fid_in_A_r, fid_in_A_i, fid_in_B_r, fid_in_B_i, fid_in_C_r, fid_in_C_i, fid_in_D_r, fid_in_D_i, ...
%fid_out_A_r, fid_out_A_i, fid_out_B_r, fid_out_B_i, fid_out_C_r, fid_out_C_i, fid_out_D_r, fid_out_D_i, ...
%fid_PI, fid_THETA_E, fid_S, ...
%seed, Iteration, first_cycle, output_cycle, symbol_number, Cycle_number, ...
%PE_number, systolic_dim, input_len, ...
%RQ_matrix, s_buf, NRMSE_buf...
%);



%% ========================================================================
% Sweep
% ========================================================================

for WH = 1:length(WL_H_list)

    for WP = 1:length(WL_P_input_list)

        for WS = 1:length(WL_S_list)

            for WPI = 1:length(WL_PI_list)

% ========================================================================>

                % =========================================================
                % Fixed-point setting
                % =========================================================

                WL_H = WL_H_list(WH);
                FL_H = WL_H - 6;


                WL_P_input = WL_P_input_list(WP);
                FL_P_input = WL_P_input - 6;


                WL_S = WL_S_list(WS);
                FL_S = WL_S - 1;


                WL_PI = WL_PI_list(WPI);
                FL_PI = WL_PI - 4;


                % =========================================================
                % Display current sweep setting
                % =========================================================

                fprintf(['WL_H:%d, WL_P_input:%d, ', ...
                         'WL_S:%d, WL_PI:%d\n'], ...
                         WL_H, WL_P_input, ...
                         WL_S, WL_PI);


                % =========================================================
                % QR decomposition
                % =========================================================

                NMSE_grid(WH, WP, WS, WPI) = ...
                    QR_top( ...
                    WL_H, FL_H, ...
                    WL_P_input, FL_P_input, ...
                    WL_S, FL_S, ...
                    WL_PI, FL_PI, ...
                    ...
                    base_dir, mode, trunc_mode, debug_mode, ...
                    ...
                    fid_in_A_r, fid_in_A_i, ...
                    fid_in_B_r, fid_in_B_i, ...
                    fid_in_C_r, fid_in_C_i, ...
                    fid_in_D_r, fid_in_D_i, ...
                    ...
                    fid_out_A_r, fid_out_A_i, ...
                    fid_out_B_r, fid_out_B_i, ...
                    fid_out_C_r, fid_out_C_i, ...
                    fid_out_D_r, fid_out_D_i, ...
                    ...
                    fid_PI, fid_THETA_E, fid_S, ...
                    ...
                    seed, Iteration, ...
                    first_cycle, output_cycle, ...
                    symbol_number, Cycle_number, ...
                    ...
                    PE_number, systolic_dim, input_len, ...
                    ...
                    RQ_matrix, s_buf, NRMSE_buf ...
                    );

% ========================================================================>

            end
        end
    end
end

%% ========================================================================
% Plot
% ========================================================================

% Fixed WL
WL_H_fixed       = 20;
WL_P_input_fixed = 19;
WL_S_fixed       = 15;
WL_PI_fixed      = 16;


% 找到對應 index
WH_fixed  = find(WL_H_list       == WL_H_fixed);
WP_fixed  = find(WL_P_input_list == WL_P_input_fixed);
WS_fixed  = find(WL_S_list       == WL_S_fixed);
WPI_fixed = find(WL_PI_list      == WL_PI_fixed);

LineWidth = 3.0;
%% ========================================================================
% Figure 60 : NMSE vs WL_H
% ========================================================================

figure(60);
hold on;
grid on;

ax = gca;
colororder(ax, turbo(1));
set(ax, 'DefaultLineMarkerSize', 7);


NMSE_curve = squeeze( ...
    NMSE_grid(:, WP_fixed, WS_fixed, WPI_fixed));


NMSE_curve(NMSE_curve <= 0) = 1e-20;


semilogy(WL_H_list, NMSE_curve, '-o', ...
    'LineWidth', LineWidth, ...
    'DisplayName', sprintf( ...
    'WL_P = %d, WL_S = %d', ...
    WL_P_input_fixed, WL_S_fixed));


xlabel('WL_{mag}');
ylabel('Normalized-RMSE');
title(sprintf('Normalized-RMSE vs WL_{mag}'));

%legend('show', ...
%       'Location', 'northeast', ...
%       'Interpreter', 'tex');

set(gca, 'YScale', 'log');

grid on;
hold off;


%% ========================================================================
% Figure 61 : NMSE vs WL_P_input
% ========================================================================

figure(61);
hold on;
grid on;

ax = gca;
colororder(ax, turbo(1));
set(ax, 'DefaultLineMarkerSize', 7);


NMSE_curve = squeeze( ...
    NMSE_grid(WH_fixed, :, WS_fixed, WPI_fixed));


NMSE_curve(NMSE_curve <= 0) = 1e-20;


semilogy(WL_P_input_list, NMSE_curve, '-o', ...
    'LineWidth', LineWidth, ...
    'DisplayName', sprintf( ...
    'WL_H = %d, WL_S = %d', ...
    WL_H_fixed, WL_S_fixed));


xlabel('WL_{Phase}');
ylabel('Normalized-RMSE');
title(sprintf('Normalized-RMSE vs WL_{Phase}'));

%legend('show', ...
%       'Location', 'northeast', ...
%       'Interpreter', 'tex');

set(gca, 'YScale', 'log');

grid on;
hold off;


%% ========================================================================
% Figure 62 : NMSE vs WL_S
% ========================================================================

figure(62);
hold on;
grid on;

ax = gca;
colororder(ax, turbo(1));
set(ax, 'DefaultLineMarkerSize', 7);


NMSE_curve = squeeze( ...
    NMSE_grid(WH_fixed, WP_fixed, :, WPI_fixed));


NMSE_curve(NMSE_curve <= 0) = 1e-20;


semilogy(WL_S_list, NMSE_curve, '-o', ...
    'LineWidth', LineWidth, ...
    'DisplayName', sprintf( ...
    'WL_H = %d, WL_P = %d', ...
    WL_H_fixed, WL_P_input_fixed));


xlabel('WL_S');
ylabel('Normalized-RMSE');
title(sprintf('Normalized-RMSE vs WL_S'));

%legend('show', ...
%       'Location', 'northeast', ...
%       'Interpreter', 'tex');

set(gca, 'YScale', 'log');

grid on;
hold off;


%% ========================================================================
% Figure 63 : NMSE vs WL_PI
% ========================================================================
%
%figure(63);
%hold on;
%grid on;
%
%ax = gca;
%colororder(ax, turbo(1));
%set(ax, 'DefaultLineMarkerSize', 7);
%
%
%NMSE_curve = squeeze( ...
%    NMSE_grid(WH_fixed, WP_fixed, WS_fixed, :));
%
%
%NMSE_curve(NMSE_curve <= 0) = 1e-20;
%
%
%semilogy(WL_PI_list, NMSE_curve, '-o', ...
%    'LineWidth', LineWidth, ...
%    'DisplayName', sprintf( ...
%    'WL_H = %d, WL_P = %d, WL_S = %d', ...
%    WL_H_fixed, WL_P_input_fixed, WL_S_fixed));
%
%
%xlabel('WL_{PI}');
%ylabel('NMSE');
%title(sprintf('NMSE vs WL_{PI}'));
%
%legend('show', ...
%       'Location', 'northeast', ...
%       'Interpreter', 'tex');
%
%set(gca, 'YScale', 'log');
%
%grid on;
%hold off;





%% ========================================================================
% Output folder
% ========================================================================

output_dir = fullfile(pwd, 'output');

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


%% Figure 60 : NMSE vs WL_H
figure(60);

savefig(gcf, fullfile(output_dir, 'NMSE_vs_WL_H.fig'));

exportgraphics(gcf, ...
    fullfile(output_dir, 'NMSE_vs_WL_H.png'), ...
    'Resolution', 300);

exportgraphics(gcf, ...
    fullfile(output_dir, 'NMSE_vs_WL_H.pdf'), ...
    'ContentType', 'vector');


%% Figure 61 : NMSE vs WL_P_input
figure(61);

savefig(gcf, fullfile(output_dir, 'NMSE_vs_WL_P_input_otherFIX.fig'));

exportgraphics(gcf, ...
    fullfile(output_dir, 'NMSE_vs_WL_P_input_otherFIX.png'), ...
    'Resolution', 300);

exportgraphics(gcf, ...
    fullfile(output_dir, 'NMSE_vs_WL_P_input_otherFIX.pdf'), ...
    'ContentType', 'vector');


%% Figure 62 : NMSE vs WL_S
figure(62);

savefig(gcf, fullfile(output_dir, 'NMSE_vs_WL_S.fig'));

exportgraphics(gcf, ...
    fullfile(output_dir, 'NMSE_vs_WL_S.png'), ...
    'Resolution', 300);

exportgraphics(gcf, ...
    fullfile(output_dir, 'NMSE_vs_WL_S.pdf'), ...
    'ContentType', 'vector');


%% Figure 63 : NMSE vs WL_PI
%figure(63);
%
%savefig(gcf, fullfile(output_dir, 'NMSE_vs_WL_PI.fig'));
%
%exportgraphics(gcf, ...
%    fullfile(output_dir, 'NMSE_vs_WL_PI.png'), ...
%    'Resolution', 300);
%
%exportgraphics(gcf, ...
%    fullfile(output_dir, 'NMSE_vs_WL_PI.pdf'), ...
%    'ContentType', 'vector');
%%
fclose(fid_in_A_r);
fclose(fid_in_A_i);
fclose(fid_in_B_r);
fclose(fid_in_B_i);
fclose(fid_in_C_r);
fclose(fid_in_C_i);
fclose(fid_in_D_r);
fclose(fid_in_D_i);

fclose(fid_out_A_r);
fclose(fid_out_A_i);
fclose(fid_out_B_r);
fclose(fid_out_B_i);
fclose(fid_out_C_r);
fclose(fid_out_C_i);
fclose(fid_out_D_r);
fclose(fid_out_D_i);

fclose(fid_PI);
fclose(fid_THETA_E);
fclose(fid_S);