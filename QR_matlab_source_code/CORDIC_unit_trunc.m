function [mag_simple, mag_strict, RealOut, ImagOut, PhaseOut] = CORDIC_unit_trunc(RealIn, ImagIn, PhaseIn, Iteration, CORDIC_mode, ...
    WL_input, FL_input, WL_P_input, FL_P_input, trunc_mode,...
    fid_PI, fid_S, fid_THETA_E, write_mode,...
    fid_out_stage1_r, fid_out_stage1_i, fid_out_stage1_p, ...
    WL_S, FL_S, WL_PI, FL_PI)
%CORDIC_VEC  Vectorized CORDIC for Vector mode and Rotation mode
%
% Inputs:
%   RealIn, ImagIn : same size arrays (vector/matrix)
%   PhaseIn        : same size (Rotation mode uses it; Vector mode can pass zeros)
%   Iteration      : nonnegative integer
%   CORDIC_mode    : "Vector" or "Rotation"
%
% Outputs (same size as inputs):
%   RealOut, ImagOut, PhaseOut

   %arguments
   %    RealIn (:,:) double
   %    ImagIn (:,:) double
   %    PhaseIn (:,:) double
   %    Iteration (1,1) {mustBeInteger, mustBeNonnegative}
   %    CORDIC_mode (1,1) string {mustBeMember(CORDIC_mode, ["Vector","Rotation"])}
   %end

    % CORDIC gain compensation
    %S = S_of_N(Iteration);
    k = 0:Iteration-1;
    S = 1 / prod(sqrt(1 + 2.^(-2*k)));

%    WL_S = 24;
%    FL_S = 23;
    S = trunc_fixed_v2(S, WL_S, FL_S, trunc_mode);
%    WL_PI = 24;
%    FL_PI = 20;
    PI_0_5_p = trunc_fixed_v2(pi/2,     WL_P_input,   FL_P_input,  trunc_mode);
    PI_1_0_p = trunc_fixed_v2(pi,       WL_P_input,   FL_P_input,  trunc_mode);
    PI_1_5_p = trunc_fixed_v2(3*pi/2,   WL_P_input,   FL_P_input,  trunc_mode);
    PI_2_0_p = trunc_fixed_v2(2*pi,     WL_P_input,   FL_P_input,  trunc_mode);    
    PI_0_5_n = trunc_fixed_v2(-pi/2,    WL_P_input,   FL_P_input,  trunc_mode);
    PI_1_0_n = trunc_fixed_v2(-pi,      WL_P_input,   FL_P_input,  trunc_mode);
    PI_1_5_n = trunc_fixed_v2(-3*pi/2,  WL_P_input,   FL_P_input,  trunc_mode);
    PI_2_0_n = trunc_fixed_v2(-2*pi,    WL_P_input,   FL_P_input,  trunc_mode);    


    % write bin men replace to trunc_fixed_v2
    if write_mode == "true"
        [S_bin, S_q] = write_bin_men(S, WL_S, FL_S, 'floor');
        fprintf(fid_S, '%s\n', S_bin);
        PI = [PI_0_5_p; PI_1_0_p; PI_1_5_p; PI_2_0_p; PI_0_5_n; PI_1_0_n; PI_1_5_n; PI_2_0_n];
        for ii = 1:numel(PI)
            [bin, q] = write_bin_men(PI(ii), WL_P_input, FL_P_input, 'floor');  % your function
            fprintf(fid_PI, '%s\n', bin);
        end
    end


    switch CORDIC_mode
        %==============================================================
        case "Vector"
        %==============================================================
            % ---- Step1. [無須trunc] Reset (vector) ----
            REG_X  = zeros(size(RealIn));
            REG_Y  = zeros(size(RealIn));
            REG_PH = zeros(size(RealIn));

            % ---- Step2. [無須trunc] Range detection (vector) ----
            negMask = (RealIn < 0.0); % AXIS_MODE = -1 when true
            INPUT_XC = RealIn;  INPUT_YC = ImagIn;
            INPUT_XC(negMask) = -RealIn(negMask);
            INPUT_YC(negMask) = -ImagIn(negMask);

            % ---- Step3. [須trunc] CORDIC iteration ----
            for k = 0:Iteration-1
                if k == 0
                    MUX_X = INPUT_XC;
                    MUX_Y = INPUT_YC;
                else
                    MUX_X = REG_X;
                    MUX_Y = REG_Y;
                end

                yNonNeg = (MUX_Y >= 0); % your "順時針" branch

                sh = 2^k;    % shift
                ADD_X  = zeros(size(MUX_X));
                ADD_Y  = zeros(size(MUX_Y));
                ADD_PH = zeros(size(REG_PH));

                % MUX_Y >= 0 [須trunc部分]
                ADD_X(yNonNeg)  = MUX_X(yNonNeg) + trunc_fixed_v2(MUX_Y(yNonNeg)/sh, WL_input, FL_input, trunc_mode);
                ADD_Y(yNonNeg)  = MUX_Y(yNonNeg) - trunc_fixed_v2(MUX_X(yNonNeg)/sh, WL_input, FL_input, trunc_mode);
                ADD_PH(yNonNeg) = REG_PH(yNonNeg) + trunc_fixed_v2(atan2(1.0, sh), WL_P_input, FL_P_input, trunc_mode);

                % MUX_Y < 0 [須trunc部分]
                yn = ~yNonNeg;
                ADD_X(yn)  = MUX_X(yn) - trunc_fixed_v2(MUX_Y(yn)/sh, WL_input, FL_input, trunc_mode);
                ADD_Y(yn)  = MUX_Y(yn) + trunc_fixed_v2(MUX_X(yn)/sh, WL_input, FL_input, trunc_mode);
                ADD_PH(yn) = REG_PH(yn) - trunc_fixed_v2(atan2(1.0, sh), WL_P_input, FL_P_input, trunc_mode);

                REG_X  = trunc_fixed_v2(ADD_X, WL_input, FL_input, trunc_mode);
                REG_Y  = trunc_fixed_v2(ADD_Y, WL_input, FL_input, trunc_mode);
                REG_PH = trunc_fixed_v2(ADD_PH, WL_P_input, FL_P_input, trunc_mode);
            end

            % ---- Step4. [須trunc] Quadrant restore ----
            PhaseOut = REG_PH;
            PhaseOut(negMask) = PI_1_0_p + REG_PH(negMask);
            PhaseOut = trunc_fixed_v2(PhaseOut, WL_P_input, FL_P_input, trunc_mode);

            RealOut = REG_X * S;
            RealOut = trunc_fixed_v2(RealOut, WL_input, FL_input, trunc_mode);
            %ImagOut = REG_Y;
            ImagOut = 0;

            % mag測試:
            R_simple = complex(RealOut, REG_Y);
            R_strict = complex(RealOut, REG_Y * S);
        
            mag_simple = abs(R_simple);
            mag_strict = abs(R_strict);
        %==============================================================
        case "Rotation"
        %==============================================================
            % ---- Step1.[不須trunc] Reset (vector) ----
            CORDIC_X = zeros(size(RealIn));
            CORDIC_Y = zeros(size(RealIn));
            CORDIC_Z = zeros(size(RealIn));

            ph = PhaseIn;

            % ---- Step2.[須trunc] Pre-rotate into residual range near [-pi/2, pi/2] ----
            % (A) + angle side: [0, 2pi)
            m1 = (ph >= 0.0)        & (ph <  PI_0_5_p);         % 0 ~  pi/2
            m2 = (ph >= PI_0_5_p)   & (ph <  PI_1_0_p);           % pi/2 ~ pi
            m3 = (ph >= PI_1_0_p)   & (ph <  PI_1_5_p);       % pi ~ 3pi/2
            m4 = (ph >= PI_1_5_p)   & (ph <  PI_2_0_p);         % 3pi/2 ~ 2pi

            % (B) - angle side: (-2pi, 0)
            m5 = (ph <  0.0)        & (ph >= PI_0_5_n);        % -pi/2 ~ 0
            m6 = (ph < PI_0_5_n)    & (ph >= PI_1_0_n);          % -pi ~ -pi/2
            m7 = (ph < PI_1_0_n)    & (ph >= PI_1_5_n);      % -3pi/2 ~ -pi
            m8 = (ph < PI_1_5_n)    & (ph >= PI_2_0_n);        % -2pi ~ -3pi/2

            % Fill per region (vectorized)
            % Region 1: pi/2 > Phase >= 0
            CORDIC_X(m1) = RealIn(m1);
            CORDIC_Y(m1) = ImagIn(m1);
            CORDIC_Z(m1) = ph(m1);

            % Region 2: pi > Phase >= pi/2   (pre-rotate +pi/2)
            CORDIC_X(m2) = -ImagIn(m2);
            CORDIC_Y(m2) =  RealIn(m2);
            CORDIC_Z(m2) =  ph(m2) - (PI_0_5_p);

            % Region 3: 3pi/2 > Phase >= pi  (pre-rotate +pi)
            CORDIC_X(m3) = -RealIn(m3);
            CORDIC_Y(m3) = -ImagIn(m3);
            CORDIC_Z(m3) =  ph(m3) - (PI_1_0_p);

            % Region 4: 2pi > Phase >= 3pi/2 (pre-rotate +3pi/2)
            CORDIC_X(m4) =  ImagIn(m4);
            CORDIC_Y(m4) = -RealIn(m4);
            CORDIC_Z(m4) =  ph(m4) - (PI_1_5_p);

            % Region 5: 0 > Phase >= -pi/2
            CORDIC_X(m5) = RealIn(m5);
            CORDIC_Y(m5) = ImagIn(m5);
            CORDIC_Z(m5) = ph(m5);

            % Region 6: -pi/2 > Phase >= -pi (pre-rotate -pi/2)
            CORDIC_X(m6) =  ImagIn(m6);
            CORDIC_Y(m6) = -RealIn(m6);
            CORDIC_Z(m6) =  ph(m6) + (PI_0_5_p);

            % Region 7: -pi > Phase >= -3pi/2 (pre-rotate -pi)
            CORDIC_X(m7) = -RealIn(m7);
            CORDIC_Y(m7) = -ImagIn(m7);
            CORDIC_Z(m7) =  ph(m7) + (PI_1_0_p);

            % Region 8: -3pi/2 >= Phase >= -2pi (pre-rotate -3pi/2)
            CORDIC_X(m8) = -ImagIn(m8);
            CORDIC_Y(m8) =  RealIn(m8);
            CORDIC_Z(m8) =  ph(m8) + (PI_1_5_p);

            validMask = (m1|m2|m3|m4|m5|m6|m7|m8);
            if any(~validMask, 'all')
                % Out of expected range: set NaN so you notice it immediately
                CORDIC_X(~validMask) = NaN;
                CORDIC_Y(~validMask) = NaN;
                CORDIC_Z(~validMask) = NaN;
                warning("PhaseIn has values outside [-2pi, 2pi). Those entries are set to NaN.");
            end

            % ---- Step3.[須trunc] CORDIC iteration (rotation mode) ----
            for k = 0:Iteration-1
                sh = 2^k;
         %       sh = trunc_fixed_v2(sh)
                %ang = atan2(1.0, sh);
                ang = trunc_fixed_v2(atan2(1.0, sh), WL_P_input, FL_P_input, trunc_mode);

                if write_mode == "true"
                   [hex_digits_x, qr, qi, qr_u, qi_u] = write_twiddle_mem_v2(complex(ang, ang), WL_P_input, FL_P_input);
                   for n = 1:numel(qi_u)
                       fprintf(fid_THETA_E,['%0', num2str(hex_digits_x), 'X\n'], qr_u(n));
                   end
                end

                zNonNeg = (CORDIC_Z >= 0); % your "逆時針轉"

                TMP_X = CORDIC_X;
                TMP_Y = CORDIC_Y;
                TMP_Z = CORDIC_Z;

                % allocate updates
                newX = TMP_X;
                newY = TMP_Y;
                newZ = TMP_Z;

                % TMP_Z >= 0 : CCW
                newX(zNonNeg) =trunc_fixed_v2( (TMP_X(zNonNeg) - trunc_fixed_v2(TMP_Y(zNonNeg)/sh, WL_input, FL_input, trunc_mode)), WL_input, FL_input, trunc_mode);
                newY(zNonNeg) =trunc_fixed_v2( (TMP_Y(zNonNeg) + trunc_fixed_v2(TMP_X(zNonNeg)/sh, WL_input, FL_input, trunc_mode)), WL_input, FL_input, trunc_mode);
                newZ(zNonNeg) =trunc_fixed_v2( (TMP_Z(zNonNeg) - ang), WL_P_input, FL_P_input, trunc_mode);

                % TMP_Z < 0 : CW
                zn = ~zNonNeg;
                newX(zn) =trunc_fixed_v2( (TMP_X(zn) + trunc_fixed_v2(TMP_Y(zn)/sh, WL_input, FL_input, trunc_mode)), WL_input, FL_input, trunc_mode);
                newY(zn) =trunc_fixed_v2( (TMP_Y(zn) - trunc_fixed_v2(TMP_X(zn)/sh, WL_input, FL_input, trunc_mode)), WL_input, FL_input, trunc_mode);
                newZ(zn) =trunc_fixed_v2( (TMP_Z(zn) + ang), WL_P_input, FL_P_input, trunc_mode);

                CORDIC_X = newX;
                CORDIC_Y = newY;
                CORDIC_Z = newZ;
                CORDIC_complex = complex(CORDIC_X(end),  CORDIC_Y(end));
                if write_mode == "true"
                   [hex_digits_x, qr, qi, qr_u, qi_u] = write_twiddle_mem_v2(CORDIC_complex, WL_input, FL_input);
                   for n = 1:numel(qr_u)
                       fprintf(fid_out_stage1_r, ['stage %d:', '%0', num2str(hex_digits_x), 'X\n'],k+1, qr_u(n));
                   end
                   for n = 1:numel(qi_u)
                       fprintf(fid_out_stage1_i, ['stage %d:', '%0', num2str(hex_digits_x), 'X\n'],k+1, qi_u(n));
                   end

                   [hex_digits_x, qr, qi, qr_u, qi_u] = write_twiddle_mem_v2(complex(CORDIC_Z(end), CORDIC_Z(end)), WL_P_input, FL_P_input);
                   for n = 1:numel(qi_u)
                       fprintf(fid_out_stage1_p, ['stage %d:', '%0', num2str(hex_digits_x), 'X\n'],k+1, qr_u(n));
                   end
                %fprintf(fid_out_stage1_r, 'stage %d: %s\n', k, CORDIC_X(100));
                end
            end

            RealOut  = CORDIC_X * S;
            ImagOut  = CORDIC_Y * S;
            RealOut = trunc_fixed_v2(RealOut, WL_input, FL_input, trunc_mode);
            ImagOut = trunc_fixed_v2(ImagOut, WL_input, FL_input, trunc_mode);
            %PhaseOut = CORDIC_Z; % residual (should approach ~0)
            PhaseOut = PhaseIn;
            
            R_strict = complex(RealOut, ImagOut);           
            mag_simple = abs(R_strict);
            mag_strict = abs(R_strict);
    end
end
