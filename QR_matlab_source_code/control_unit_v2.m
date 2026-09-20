function PE_control = control_unit_v2(Cycle, output_cycle, PE_number)
    if mod(Cycle, output_cycle) == 0
        PE_control = zeros(PE_number, 1);
        PE_control(6) = 1;   

    elseif mod(Cycle, output_cycle) == 2
        PE_control = zeros(PE_number, 1);
        PE_control(1) = 1;   
        PE_control(7) = 1;   

    elseif mod(Cycle, output_cycle) == 3
        PE_control = zeros(PE_number, 1);
        PE_control(2) = 1;  

    elseif mod(Cycle, output_cycle) == 4
        PE_control = zeros(PE_number, 1);
        PE_control(3) = 1;  

    elseif mod(Cycle, output_cycle) == 5
        PE_control = zeros(PE_number, 1);
        PE_control(4) = 1;  

    elseif mod(Cycle, output_cycle) == 6
        PE_control = zeros(PE_number, 1);
        PE_control(5) = 1;  

    %elseif mod(Cycle, output_cycle) == 8
    %    PE_control = zeros(PE_number, 1);
    %    PE_control(6) = 1;  

    else
       PE_control = zeros(PE_number, 1);
    end
end