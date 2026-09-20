function [RealOut, ImagOut, PhaseOut] = CORDIC_unit(RealIn, ImagIn, PhaseIn, Iteration, CORDIC_mode)
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

    arguments
        RealIn (:,:) double
        ImagIn (:,:) double
        PhaseIn (:,:) double
        Iteration (1,1) {mustBeInteger, mustBeNonnegative}
        CORDIC_mode (1,1) string {mustBeMember(CORDIC_mode, ["Vector","Rotation"])}
    end

    % CORDIC gain compensation
    %S = S_of_N(Iteration);
    k = 0:Iteration;
    S = 1 / prod(sqrt(1 + 2.^(-2*k)));

    switch CORDIC_mode
        %==============================================================
        case "Vector"
        %==============================================================
            % ---- Step1. Reset (vector) ----
            REG_X  = zeros(size(RealIn));
            REG_Y  = zeros(size(RealIn));
            REG_PH = zeros(size(RealIn));

            % ---- Step2. Range detection (vector) ----
            negMask = (RealIn < 0.0); % AXIS_MODE = -1 when true
            INPUT_XC = RealIn;  INPUT_YC = ImagIn;
            INPUT_XC(negMask) = -RealIn(negMask);
            INPUT_YC(negMask) = -ImagIn(negMask);

            % ---- Step3. CORDIC iteration ----
            for k = 0:Iteration
                if k == 0
                    MUX_X = INPUT_XC;
                    MUX_Y = INPUT_YC;
                else
                    MUX_X = REG_X;
                    MUX_Y = REG_Y;
                end

                yNonNeg = (MUX_Y >= 0); % your "順時針" branch

                sh = 2^k;
                ADD_X  = zeros(size(MUX_X));
                ADD_Y  = zeros(size(MUX_Y));
                ADD_PH = zeros(size(REG_PH));

                % MUX_Y >= 0
                ADD_X(yNonNeg)  = MUX_X(yNonNeg) + MUX_Y(yNonNeg)/sh;
                ADD_Y(yNonNeg)  = MUX_Y(yNonNeg) - MUX_X(yNonNeg)/sh;
                ADD_PH(yNonNeg) = REG_PH(yNonNeg) + atan2(1.0, sh);

                % MUX_Y < 0
                yn = ~yNonNeg;
                ADD_X(yn)  = MUX_X(yn) - MUX_Y(yn)/sh;
                ADD_Y(yn)  = MUX_Y(yn) + MUX_X(yn)/sh;
                ADD_PH(yn) = REG_PH(yn) - atan2(1.0, sh);

                REG_X  = ADD_X;
                REG_Y  = ADD_Y;
                REG_PH = ADD_PH;
            end

            % ---- Step4. Quadrant restore ----
            PhaseOut = REG_PH;
            PhaseOut(negMask) = pi + REG_PH(negMask);

            RealOut = REG_X * S;
            ImagOut = REG_Y;

        %==============================================================
        case "Rotation"
        %==============================================================
            % ---- Step1. Reset (vector) ----
            CORDIC_X = zeros(size(RealIn));
            CORDIC_Y = zeros(size(RealIn));
            CORDIC_Z = zeros(size(RealIn));

            ph = PhaseIn;

            % ---- Step2. Pre-rotate into residual range near [-pi/2, pi/2] ----
            % (A) + angle side: [0, 2pi)
            m1 = (ph >= 0.0)        & (ph <  pi/2);         % 0 ~  pi/2
            m2 = (ph >= pi/2)       & (ph <  pi);           % pi/2 ~ pi
            m3 = (ph >= pi)         & (ph <  3*pi/2);       % pi ~ 3pi/2
            m4 = (ph >= 3*pi/2)     & (ph <  2*pi);         % 3pi/2 ~ 2pi

            % (B) - angle side: (-2pi, 0)
            m5 = (ph <  0.0)        & (ph >= -pi/2);        % -pi/2 ~ 0
            m6 = (ph < -pi/2)       & (ph >= -pi);          % -pi ~ -pi/2
            m7 = (ph < -pi)         & (ph >= -3*pi/2);      % -3pi/2 ~ -pi
            m8 = (ph < -3*pi/2)     & (ph >= -2*pi);        % -2pi ~ -3pi/2

            % Fill per region (vectorized)
            % Region 1: pi/2 > Phase >= 0
            CORDIC_X(m1) = RealIn(m1);
            CORDIC_Y(m1) = ImagIn(m1);
            CORDIC_Z(m1) = ph(m1);

            % Region 2: pi > Phase >= pi/2   (pre-rotate +pi/2)
            CORDIC_X(m2) = -ImagIn(m2);
            CORDIC_Y(m2) =  RealIn(m2);
            CORDIC_Z(m2) =  ph(m2) - (pi/2);

            % Region 3: 3pi/2 > Phase >= pi  (pre-rotate +pi)
            CORDIC_X(m3) = -RealIn(m3);
            CORDIC_Y(m3) = -ImagIn(m3);
            CORDIC_Z(m3) =  ph(m3) - pi;

            % Region 4: 2pi > Phase >= 3pi/2 (pre-rotate +3pi/2)
            CORDIC_X(m4) =  ImagIn(m4);
            CORDIC_Y(m4) = -RealIn(m4);
            CORDIC_Z(m4) =  ph(m4) - (3*pi/2);

            % Region 5: 0 > Phase >= -pi/2
            CORDIC_X(m5) = RealIn(m5);
            CORDIC_Y(m5) = ImagIn(m5);
            CORDIC_Z(m5) = ph(m5);

            % Region 6: -pi/2 > Phase >= -pi (pre-rotate -pi/2)
            CORDIC_X(m6) =  ImagIn(m6);
            CORDIC_Y(m6) = -RealIn(m6);
            CORDIC_Z(m6) =  ph(m6) + (pi/2);

            % Region 7: -pi > Phase >= -3pi/2 (pre-rotate -pi)
            CORDIC_X(m7) = -RealIn(m7);
            CORDIC_Y(m7) = -ImagIn(m7);
            CORDIC_Z(m7) =  ph(m7) + pi;

            % Region 8: -3pi/2 >= Phase >= -2pi (pre-rotate -3pi/2)
            CORDIC_X(m8) = -ImagIn(m8);
            CORDIC_Y(m8) =  RealIn(m8);
            CORDIC_Z(m8) =  ph(m8) + (3*pi/2);

            validMask = (m1|m2|m3|m4|m5|m6|m7|m8);
            if any(~validMask, 'all')
                % Out of expected range: set NaN so you notice it immediately
                CORDIC_X(~validMask) = NaN;
                CORDIC_Y(~validMask) = NaN;
                CORDIC_Z(~validMask) = NaN;
                warning("PhaseIn has values outside [-2pi, 2pi). Those entries are set to NaN.");
            end

            % ---- Step3. CORDIC iteration (rotation mode) ----
            for k = 0:Iteration
                sh = 2^k;
                ang = atan2(1.0, sh);

                zNonNeg = (CORDIC_Z >= 0); % your "逆時針轉"

                TMP_X = CORDIC_X;
                TMP_Y = CORDIC_Y;
                TMP_Z = CORDIC_Z;

                % allocate updates
                newX = TMP_X;
                newY = TMP_Y;
                newZ = TMP_Z;

                % TMP_Z >= 0 : CCW
                newX(zNonNeg) = TMP_X(zNonNeg) - TMP_Y(zNonNeg)/sh;
                newY(zNonNeg) = TMP_Y(zNonNeg) + TMP_X(zNonNeg)/sh;
                newZ(zNonNeg) = TMP_Z(zNonNeg) - ang;

                % TMP_Z < 0 : CW
                zn = ~zNonNeg;
                newX(zn) = TMP_X(zn) + TMP_Y(zn)/sh;
                newY(zn) = TMP_Y(zn) - TMP_X(zn)/sh;
                newZ(zn) = TMP_Z(zn) + ang;

                CORDIC_X = newX;
                CORDIC_Y = newY;
                CORDIC_Z = newZ;
            end

            RealOut  = CORDIC_X * S;
            ImagOut  = CORDIC_Y * S;
            PhaseOut = PhaseIn; % residual (should approach ~0)
    end
end