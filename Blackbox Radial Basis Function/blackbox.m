Infunction f = blackbox(dial_1, dial_2, dial_3, type)

switch type
    case 0
        f = dial_1^2 + dial_2^2 + dial_3^2;
        
    case 1
        f = sin(dial_1) + cos(dial_2) + tan(dial_3);
        
    case 2
        f = exp(dial_1 * dial_2) - log(1 + abs(dial_3));
        
    case 3
        f = abs(dial_1 - dial_2) * sqrt(abs(dial_3));
        
    case 4
        f = dial_1 * dial_2 * dial_3 + dial_1^2 - dial_2^2 + dial_3^3;
        
    case 5
        f = (dial_1 + dial_2 + dial_3) / (1 + abs(dial_1 * dial_2 * dial_3));
        
    case 6
        f = atan(dial_1) + atan(dial_2 * dial_3) + exp(-dial_1 * dial_3);
        
    case 7
        f = (dial_1^3 + dial_2^3 + dial_3^3) / (1 + dial_1^2 + dial_2^2 + dial_3^2);
        
    case 8
        f = (sin(dial_1 * dial_2) + cos(dial_2 * dial_3) + sin(dial_3 * dial_1)) * dial_3;
        
    case 9
        f = log(1 + abs(dial_1)) * exp(-abs(dial_2 * dial_3));
        
    otherwise
        disp("Enter type between 0 to 9")
        f = NaN; % Assign NaN if type is out of range
end

end
