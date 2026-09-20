function NRMSE_mean = QR_top(WL_H, FL_H, WL_P_input, FL_P_input, WL_S, FL_S, WL_PI, FL_PI, ...
base_dir, mode, trunc_mode, debug_mode, ...
fid_in_A_r, fid_in_A_i, fid_in_B_r, fid_in_B_i, fid_in_C_r, fid_in_C_i, fid_in_D_r, fid_in_D_i, ...
fid_out_A_r, fid_out_A_i, fid_out_B_r, fid_out_B_i, fid_out_C_r, fid_out_C_i, fid_out_D_r, fid_out_D_i, ...
fid_PI, fid_THETA_E, fid_S, ...
seed, Iteration, first_cycle, output_cycle, symbol_number, Cycle_number, ...
PE_number, systolic_dim, input_len, ...
RQ_matrix, s_buf, NRMSE_buf...
)
%==================================================================
if debug_mode == "true"
    fname_out_stage1_r = fullfile(base_dir, "out_stage1_r.mem");
    fname_out_stage1_i = fullfile(base_dir, "out_stage1_i.mem");
    fname_out_stage1_p = fullfile(base_dir, "out_stage1_p.mem");
   
    % --- Output debug real ---
    fid_out_stage1_r = fopen(fname_out_stage1_r, 'w');
    if fid_out_stage1_r < 0
        error('Cannot open file for writing: %s', fname_out_stage1_r);
    end
    % --- Output debug imag ---
    fid_out_stage1_i = fopen(fname_out_stage1_i, 'w');
    if fid_out_stage1_i < 0
        error('Cannot open file for writing: %s', fname_out_stage1_i);
    end

    % ---  Output debug phase ---
    fid_out_stage1_p = fopen(fname_out_stage1_p, 'w');
    if fid_out_stage1_p < 0
        error('Cannot open file for writing: %s', fname_out_stage1_p);
    end

end
%==================================================================
H = zeros(4,4) + 1j*zeros(4,4);
R = zeros(4,4) + 1j*zeros(4,4);
Q = zeros(4,4) + 1j*zeros(4,4);
symbol = 1;

    % 0. input buffer (complex):
input_A_vec_r = zeros(output_cycle, 1);
input_B_vec_r = zeros(output_cycle, 1);
input_C_vec_r = zeros(output_cycle, 1);
input_D_vec_r = zeros(output_cycle, 1);
input_A_vec_i = zeros(output_cycle, 1);
input_B_vec_i = zeros(output_cycle, 1);
input_C_vec_i = zeros(output_cycle, 1);
input_D_vec_i = zeros(output_cycle, 1);

    % input A:
input_A_vec_r(1:systolic_dim, 1) = real(H(1,:));
input_A_vec_r(systolic_dim + 1, 1) = 1;
input_A_vec_i(1:systolic_dim, 1) = imag(H(1,:));

    % input B:
input_B_vec_r(1:systolic_dim, 1) = real(H(2,:));
input_B_vec_r(systolic_dim + 2, 1) = 1;
input_B_vec_i(1:systolic_dim, 1) = imag(H(2,:));

    % input C:
input_C_vec_r(1:systolic_dim, 1) = real(H(3,:));
input_C_vec_r(systolic_dim + 3, 1) = 1;
input_C_vec_i(1:systolic_dim, 1) = imag(H(3,:));

    % input D:
input_D_vec_r(1:systolic_dim, 1) = real(H(4,:));
input_D_vec_r(systolic_dim + 4, 1) = 1;
input_D_vec_i(1:systolic_dim, 1) = imag(H(4,:));

%%
    % 1. control signal (real):
PE_control = zeros(PE_number, 1);

    % 2. DFF宣告:
    % [1.] delay buffer/element (complex):
direction = "right";
DU1_r = zeros(1, 1);    % 內部架構
DU1_i = zeros(1, 1);    % 內部架構
DU2_r = zeros(1, 1);    % 內部架構
DU2_i = zeros(1, 1);    % 內部架構
DU3_r = zeros(1, 1);    % 內部架構
DU3_i = zeros(1, 1);    % 內部架構


DL2_r = zeros(1, 1);  % Delay Line
DL2_i = zeros(1, 1);  % Delay Line
DL3_r = zeros(1, 2);  % Delay Line
DL3_i = zeros(1, 2);  % Delay Line
DL4_r = zeros(1, 3);  % Delay Line
DL4_i = zeros(1, 3);  % Delay Line

    % [2.] PE 內部 (real):
D_11_PE1 = zeros(1, 1);
D_12_PE1 = zeros(1, 1);
D_21_PE1 = zeros(1, 1);
D_22_PE1 = zeros(1, 1);
D_11_PE2 = zeros(1, 1);
D_12_PE2 = zeros(1, 1);
D_21_PE2 = zeros(1, 1);
D_22_PE2 = zeros(1, 1);
D_11_PE3 = zeros(1, 1);
D_12_PE3 = zeros(1, 1);
D_21_PE3 = zeros(1, 1);
D_22_PE3 = zeros(1, 1);
D_11_PE4 = zeros(1, 1);
D_12_PE4 = zeros(1, 1);
D_21_PE4 = zeros(1, 1);
D_22_PE4 = zeros(1, 1);
D_11_PE5 = zeros(1, 1);
D_12_PE5 = zeros(1, 1);
D_21_PE5 = zeros(1, 1);
D_22_PE5 = zeros(1, 1);
D_11_PE6 = zeros(1, 1);
D_12_PE6 = zeros(1, 1);
D_21_PE6 = zeros(1, 1);
D_22_PE6 = zeros(1, 1);
D_PE7 = zeros(1, 1);
    % [3.] PE output (complex):
    % 每個PE都要有四個 (除了第七個RU只要兩個) (total 6 * 4 +2 = 26個)
D_PE1_A_r = zeros(1, 1);
D_PE1_A_i = zeros(1, 1);
D_PE1_B_r = zeros(1, 1);
D_PE1_B_i = zeros(1, 1);
D_PE2_A_r = zeros(1, 1);
D_PE2_A_i = zeros(1, 1);
D_PE2_B_r = zeros(1, 1);
D_PE2_B_i = zeros(1, 1);
D_PE3_A_r = zeros(1, 1);
D_PE3_A_i = zeros(1, 1);
D_PE3_B_r = zeros(1, 1);
D_PE3_B_i = zeros(1, 1);
D_PE4_A_r = zeros(1, 1);
D_PE4_A_i = zeros(1, 1);
D_PE4_B_r = zeros(1, 1);
D_PE4_B_i = zeros(1, 1);
D_PE5_A_r = zeros(1, 1);
D_PE5_A_i = zeros(1, 1);
D_PE5_B_r = zeros(1, 1);
D_PE5_B_i = zeros(1, 1);
D_PE6_A_r = zeros(1, 1);
D_PE6_A_i = zeros(1, 1);
D_PE6_B_r = zeros(1, 1);
D_PE6_B_i = zeros(1, 1);
D_PE7_A_r = zeros(1, 1);
D_PE7_A_i = zeros(1, 1);

DU1_buffer_r = zeros(1, 3);    % 內部架構
DU1_buffer_i = zeros(1, 3);    % 內部架構
DU2_buffer_r = zeros(1, 2);    % 內部架構
DU2_buffer_i = zeros(1, 2);    % 內部架構
DU3_buffer_r = zeros(1, 1);    % 內部架構
DU3_buffer_i = zeros(1, 1);    % 內部架構

for Cycle = 1:Cycle_number
    % step0. 產生測試H (要有reg比對):
    Cycle_mod = mod(Cycle, output_cycle);
    if (Cycle_mod == 1)
        % 0) 暫存前一筆H
        H_buf = H;
        R_buf = R;
        Q_buf = Q;
        % 1) Generate a 4x4 complex matrix (reproducible)
        rng(seed);                          % fixed seed
        H = randn(systolic_dim, systolic_dim) + 1j*randn(systolic_dim, systolic_dim);      % complex Gaussian matrix
%-----------------------------------------------------------------------------------------        
        [hex_digits, qr1, qi1, qr_u, qi_u] = write_twiddle_mem_v2(H, WL_H, FL_H);
        H = trunc_fixed_v2(H, WL_H, FL_H, trunc_mode);
%-----------------------------------------------------------------------------------------   

        % 2) MATLAB QR decomposition
        [Q, R] = qr(H);                      % economy/full are same for 4x4

        % 3) 更新seed
        seed = seed + 1; 
    end
    % new step1. 設定當前input
    if (Cycle <= input_len)
        if (Cycle_mod == 1) % 更新整個input vector
                % input A:
            input_A_vec_r(1:systolic_dim, 1) = real(H(1,:));
            input_A_vec_r(systolic_dim + 1, 1) = 1;
            input_A_vec_i(1:systolic_dim, 1) = imag(H(1,:));
            
                % input B:
            input_B_vec_r(1:systolic_dim, 1) = real(H(2,:));
            input_B_vec_r(systolic_dim + 2, 1) = 1;
            input_B_vec_i(1:systolic_dim, 1) = imag(H(2,:));
            
                % input C:
            input_C_vec_r(1:systolic_dim, 1) = real(H(3,:));
            input_C_vec_r(systolic_dim + 3, 1) = 1;
            input_C_vec_i(1:systolic_dim, 1) = imag(H(3,:));
            
                % input D:
            input_D_vec_r(1:systolic_dim, 1) = real(H(4,:));
            input_D_vec_r(systolic_dim + 4, 1) = 1;
            input_D_vec_i(1:systolic_dim, 1) = imag(H(4,:));

            % write output file:
% ============================================================>
            % input A:
           [hex_digits_A, qAr, qAi, qAr_u, qAi_u] = ...
               write_twiddle_mem_v2(complex(input_A_vec_r, input_A_vec_i), WL_H, FL_H);
           for n = 1:numel(qAr_u)
               fprintf(fid_in_A_r, ['%0', num2str(hex_digits_A), 'X\n'], qAr_u(n));
           end
           for n = 1:numel(qAr_u)
               fprintf(fid_in_A_i, ['%0', num2str(hex_digits_A), 'X\n'], qAi_u(n));
           end  

            % input B:
           [hex_digits_B, qBr, qBi, qBr_u, qBi_u] = ...
               write_twiddle_mem_v2(complex(input_B_vec_r, input_B_vec_i), WL_H, FL_H);
           for n = 1:numel(qBr_u)
               fprintf(fid_in_B_r, ['%0', num2str(hex_digits_B), 'X\n'], qBr_u(n));
           end
           for n = 1:numel(qBr_u)
               fprintf(fid_in_B_i, ['%0', num2str(hex_digits_B), 'X\n'], qBi_u(n));
           end

            % input C:           
           [hex_digits_C, qCr, qCi, qCr_u, qCi_u] = ...
               write_twiddle_mem_v2(complex(input_C_vec_r, input_C_vec_i), WL_H, FL_H);
           for n = 1:numel(qCr_u)
               fprintf(fid_in_C_r, ['%0', num2str(hex_digits_C), 'X\n'], qCr_u(n));
           end
           for n = 1:numel(qCr_u)
               fprintf(fid_in_C_i, ['%0', num2str(hex_digits_C), 'X\n'], qCi_u(n));
           end  

            % input D:           
           [hex_digits_D, qDr, qDi, qDr_u, qDi_u] = ...
               write_twiddle_mem_v2(complex(input_D_vec_r, input_D_vec_i), WL_H, FL_H);
           for n = 1:numel(qDr_u)
               fprintf(fid_in_D_r, ['%0', num2str(hex_digits_D), 'X\n'], qDr_u(n));
           end
           for n = 1:numel(qDr_u)
               fprintf(fid_in_D_i, ['%0', num2str(hex_digits_D), 'X\n'], qDi_u(n));
           end  
% ============================================================>
        end

        if Cycle_mod == 0
            Cycle_mod_reorder = output_cycle;
            
        else
            Cycle_mod_reorder = Cycle_mod;
        end
        input_A_r = input_A_vec_r(Cycle_mod_reorder);
        input_B_r = input_B_vec_r(Cycle_mod_reorder);
        input_C_r = input_C_vec_r(Cycle_mod_reorder);
        input_D_r = input_D_vec_r(Cycle_mod_reorder);
        input_A_i = input_A_vec_i(Cycle_mod_reorder);
        input_B_i = input_B_vec_i(Cycle_mod_reorder);
        input_C_i = input_C_vec_i(Cycle_mod_reorder);
        input_D_i = input_D_vec_i(Cycle_mod_reorder); 
%if Cycle == 8
%    disp("121331");
%        input_A_r = 0;
%        input_B_r = 0;
%        input_C_r = 0;
%        input_D_r = 1;
%        input_A_i = 0;
%        input_B_i = 0;
%        input_C_i = 0;
%        input_D_i = 0;
%end

    else
        input_A_r = 0;
        input_B_r = 0;
        input_C_r = 0;
        input_D_r = 0;
        input_A_i = 0;
        input_B_i = 0;
        input_C_i = 0;
        input_D_i = 0;  
    end
    % step2. 設定控制訊號:
    PE_control = control_unit_v2(Cycle, output_cycle, PE_number);
    PE_control_s = repmat("Rotation", size(PE_control)); % 先全部設 Rotation
    PE_control_s(PE_control==1) = "Vector";              % PE_control==1 的位置改成 Vector

    % step3. 外圍暫存器shift一格:
    [DU1_r, DU1_out_r] = shift_reg(DU1_r, input_A_r, direction);
    [DL2_r, DL2_out_r] = shift_reg(DL2_r, input_B_r, direction);
    [DL3_r, DL3_out_r] = shift_reg(DL3_r, input_C_r, direction);
    [DL4_r, DL4_out_r] = shift_reg(DL4_r, input_D_r, direction);
    [DU1_i, DU1_out_i] = shift_reg(DU1_i, input_A_i, direction);
    [DL2_i, DL2_out_i] = shift_reg(DL2_i, input_B_i, direction);
    [DL3_i, DL3_out_i] = shift_reg(DL3_i, input_C_i, direction);
    [DL4_i, DL4_out_i] = shift_reg(DL4_i, input_D_i, direction);


    % systolic array:
            % PE1: [A向右，B向下]
    [DU1_out_PE1_r, DU1_out_PE1_i, DL2_out_PE1_r, DL2_out_PE1_i, ...
    D_11_PE1, D_12_PE1, D_21_PE1, D_22_PE1, ...
    D_PE1_A_r, D_PE1_A_i, D_PE1_B_r, D_PE1_B_i] = ...
    COMPLEX_PE_out_D(...
    DU1_out_r, DU1_out_i, DL2_out_r, DL2_out_i, ...
    Iteration, PE_control_s(1), direction,...
    D_11_PE1, D_12_PE1, D_21_PE1, D_22_PE1, ...
    D_PE1_A_r, D_PE1_A_i, D_PE1_B_r, D_PE1_B_i,...
        ...
        WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
        fid_PI, fid_S, fid_THETA_E, ...
        fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);

            % PE2:
    [DU1_out_PE2_r, DU1_out_PE2_i, DL3_out_PE2_r, DL3_out_PE2_i, ...
    D_11_PE2, D_12_PE2, D_21_PE2, D_22_PE2, ...
    D_PE2_A_r, D_PE2_A_i, D_PE2_B_r, D_PE2_B_i] = ...
    COMPLEX_PE_out_D(...
    DU1_out_PE1_r, DU1_out_PE1_i, DL3_out_r, DL3_out_i, ...
    Iteration, PE_control_s(2), direction,...
    D_11_PE2, D_12_PE2, D_21_PE2, D_22_PE2, ...
    D_PE2_A_r, D_PE2_A_i, D_PE2_B_r, D_PE2_B_i,...
        ...
        WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
        fid_PI, fid_S, fid_THETA_E, ...
        fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);    
    
            % PE3:
    [DU1_out_PE3_r, DU1_out_PE3_i, DL4_out_PE3_r, DL4_out_PE3_i, ...
    D_11_PE3, D_12_PE3, D_21_PE3, D_22_PE3, ...
    D_PE3_A_r, D_PE3_A_i, D_PE3_B_r, D_PE3_B_i] = ...
    COMPLEX_PE_out_D(...
    DU1_out_PE2_r, DU1_out_PE2_i, DL4_out_r, DL4_out_i, ...
    Iteration, PE_control_s(3), direction,...
    D_11_PE3, D_12_PE3, D_21_PE3, D_22_PE3, ...
    D_PE3_A_r, D_PE3_A_i, D_PE3_B_r, D_PE3_B_i,...
        ...
        WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
        fid_PI, fid_S, fid_THETA_E, ...
        fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);

%===============================================================================================
        % DL2_out轉彎至DU2:
    [DU2_r, DU2_out_r] = shift_reg(DU2_r, DL2_out_PE1_r, direction);
    [DU2_i, DU2_out_i] = shift_reg(DU2_i, DL2_out_PE1_i, direction);

            % PE4:
    [DU2_out_PE4_r, DU2_out_PE4_i, DL3_out_PE4_r, DL3_out_PE4_i, ...
    D_11_PE4, D_12_PE4, D_21_PE4, D_22_PE4, ...
    D_PE4_A_r, D_PE4_A_i, D_PE4_B_r, D_PE4_B_i] = ...
    COMPLEX_PE_out_D(...
    DU2_out_r, DU2_out_i, DL3_out_PE2_r, DL3_out_PE2_i, ...
    Iteration, PE_control_s(4), direction,...
    D_11_PE4, D_12_PE4, D_21_PE4, D_22_PE4, ...
    D_PE4_A_r, D_PE4_A_i, D_PE4_B_r, D_PE4_B_i,...
        ...
        WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
        fid_PI, fid_S, fid_THETA_E, ...
        fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);
    
            % PE5:
    [DU2_out_PE5_r, DU2_out_PE5_i, DL4_out_PE5_r, DL4_out_PE5_i, ...
    D_11_PE5, D_12_PE5, D_21_PE5, D_22_PE5, ...
    D_PE5_A_r, D_PE5_A_i, D_PE5_B_r, D_PE5_B_i] = ...
    COMPLEX_PE_out_D(...
    DU2_out_PE4_r, DU2_out_PE4_i, DL4_out_PE3_r, DL4_out_PE3_i, ...
    Iteration, PE_control_s(5), direction,...
    D_11_PE5, D_12_PE5, D_21_PE5, D_22_PE5, ...
    D_PE5_A_r, D_PE5_A_i, D_PE5_B_r, D_PE5_B_i,...
        ...
        WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
        fid_PI, fid_S, fid_THETA_E, ...
        fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);

%===============================================================================================
        % DL3_out轉彎至DU3:
    [DU3_r, DU3_out_r] = shift_reg(DU3_r, DL3_out_PE4_r, direction);
    [DU3_i, DU3_out_i] = shift_reg(DU3_i, DL3_out_PE4_i, direction);

        % PE6:
    [DU3_out_PE6_r, DU3_out_PE6_i, DL4_out_PE6_r, DL4_out_PE6_i, ...
    D_11_PE6, D_12_PE6, D_21_PE6, D_22_PE6, ...
    D_PE6_A_r, D_PE6_A_i, D_PE6_B_r, D_PE6_B_i] = ...
    COMPLEX_PE_out_D(...
    DU3_out_r, DU3_out_i, DL4_out_PE5_r, DL4_out_PE5_i, ...
    Iteration, PE_control_s(6), direction,...
    D_11_PE6, D_12_PE6, D_21_PE6, D_22_PE6, ...
    D_PE6_A_r, D_PE6_A_i, D_PE6_B_r, D_PE6_B_i,...
        ...
        WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
        fid_PI, fid_S, fid_THETA_E, ...
        fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);

%===============================================================================================
        % PE7: 單一CORDIC C2Z:
    if Cycle == 1
        write_S = "true";
    else
        write_S = "fasle";
    end

%   [RU4_out_r, RU4_out_i, D_PE7_temp] = CORDIC_unit(DL4_out_PE6_r, DL4_out_PE6_i, D_PE7, Iteration, PE_control_s(7));
    [mag_simple, mag_strict, RU4_out_r, RU4_out_i, D_PE7_temp] = ...
    CORDIC_unit_trunc(DL4_out_PE6_r, DL4_out_PE6_i, D_PE7, Iteration, PE_control_s(7), ...
    WL_H, FL_H, WL_P_input, FL_P_input, trunc_mode,...
    fid_PI, fid_S, fid_THETA_E, write_S,...
    fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI);

   if PE_control_s(7) == "Vector"
      D_PE7 = -D_PE7_temp;
   elseif PE_control_s(7) == "Rotation"
      D_PE7 = D_PE7_temp;
   end
   [D_PE7_A_r, DU4_out_buffer_r] = shift_reg(D_PE7_A_r, RU4_out_r, direction);
   [D_PE7_A_i, DU4_out_buffer_i] = shift_reg(D_PE7_A_i, RU4_out_i, direction);


   [DU1_buffer_r, DU1_out_buffer_r] = shift_reg(DU1_buffer_r, DU1_out_PE3_r, direction);
   [DU1_buffer_i, DU1_out_buffer_i] = shift_reg(DU1_buffer_i, DU1_out_PE3_i, direction);
   [DU2_buffer_r, DU2_out_buffer_r] = shift_reg(DU2_buffer_r, DU2_out_PE5_r, direction);
   [DU2_buffer_i, DU2_out_buffer_i] = shift_reg(DU2_buffer_i, DU2_out_PE5_i, direction);
   [DU3_buffer_r, DU3_out_buffer_r] = shift_reg(DU3_buffer_r, DU3_out_PE6_r, direction);
   [DU3_buffer_i, DU3_out_buffer_i] = shift_reg(DU3_buffer_i, DU3_out_PE6_i, direction);


   if (Cycle >= output_cycle)
         out_vec = [complex(DU1_out_buffer_r, DU1_out_buffer_i);...
             complex(DU2_out_buffer_r, DU2_out_buffer_i);...
             complex(DU3_out_buffer_r, DU3_out_buffer_i);...
             complex(DU4_out_buffer_r, DU4_out_buffer_i)];
 
         col_number = mod(Cycle, output_cycle) + 1;
         RQ_matrix(:, col_number) = out_vec;
 
         if (col_number == output_cycle)
             R_C = RQ_matrix(1:systolic_dim,1:systolic_dim);
             Q_C_H = RQ_matrix(1:systolic_dim,(systolic_dim+1):(systolic_dim*2));
             Q_C = Q_C_H';
             H_C = Q_C * R_C;
 
             tol = 1e-3;
             NRMSE_tol = 0.5 * 1e-3;
             check = abs(H_C - H_buf) < tol;
             s = sum(check, 'all');      % R2018b+
             s_buf(symbol, 1) = s;
 
             nrmse = calc_nrmse_2d(H_C, H_buf);
           %   rmse = calc_rmse_2d(H_C, H_buf);
             NRMSE_buf(symbol, 1) = nrmse;
             NRMSE_buf(symbol, 2) = nrmse <= NRMSE_tol;
             symbol = symbol +  1;
 

             % write output file:
 % ============================================================>
             % output A:
            [hex_digits_A, qAr, qAi, qAr_u, qAi_u] = ...
                write_twiddle_mem_v2(RQ_matrix(1,:), WL_H, FL_H);
            for n = 1:numel(qAr_u)
                fprintf(fid_out_A_r, ['%0', num2str(hex_digits_A), 'X\n'], qAr_u(n));
            end
            for n = 1:numel(qAr_u)
                fprintf(fid_out_A_i, ['%0', num2str(hex_digits_A), 'X\n'], qAi_u(n));
            end  
 
             % output B:
            [hex_digits_B, qBr, qBi, qBr_u, qBi_u] = ...
                write_twiddle_mem_v2(RQ_matrix(2,:), WL_H, FL_H);
            for n = 1:numel(qBr_u)
                fprintf(fid_out_B_r, ['%0', num2str(hex_digits_B), 'X\n'], qBr_u(n));
            end
            for n = 1:numel(qBr_u)
                fprintf(fid_out_B_i, ['%0', num2str(hex_digits_B), 'X\n'], qBi_u(n));
            end
 
             % output C:           
            [hex_digits_C, qCr, qCi, qCr_u, qCi_u] = ...
                write_twiddle_mem_v2(RQ_matrix(3,:), WL_H, FL_H);
            for n = 1:numel(qCr_u)
                fprintf(fid_out_C_r, ['%0', num2str(hex_digits_C), 'X\n'], qCr_u(n));
            end
            for n = 1:numel(qCr_u)
                fprintf(fid_out_C_i, ['%0', num2str(hex_digits_C), 'X\n'], qCi_u(n));
            end  
 
             % output D:           
            [hex_digits_D, qDr, qDi, qDr_u, qDi_u] = ...
                write_twiddle_mem_v2(RQ_matrix(4,:), WL_H, FL_H);
            for n = 1:numel(qDr_u)
                fprintf(fid_out_D_r, ['%0', num2str(hex_digits_D), 'X\n'], qDr_u(n));
            end
            for n = 1:numel(qDr_u)
                fprintf(fid_out_D_i, ['%0', num2str(hex_digits_D), 'X\n'], qDi_u(n));
            end  
 % ============================================================>
         end
    end


end
NRMSE_mean = mean(NRMSE_buf(:,1), 'omitnan');


s_idx = find(s_buf ~= 16);
if debug_mode == "true"
    fclose(fid_out_stage1_r);  
    fclose(fid_out_stage1_i);
    fclose(fid_out_stage1_p);
end

end
