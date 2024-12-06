function A0 = Shadow_Cal(x,h,kw,Radii)
% Calculates area of shadowing of the upstream turbine wake

if h - Radii(2) < -Radii(1) - kw*x && h + Radii(2) > Radii(1) + kw*x 
    % If wake is encapsulated by downstream turbine, area of shadowing is
    % the area of upstream rotar
    A0 = pi*Radii(1)^2;

elseif h - Radii(2) < -Radii(1) - kw*x || h + Radii(2) > Radii(1) + kw*x 
    % If at least one side of downstream turbine falls outside of wake 

    if  h + Radii(2) < -Radii(1) - kw*x || h - Radii(2) > Radii(1) + kw*x 
        % If entire downstream turbine falls outside of wake, area of
        % shadowing is 0
        A0 = 0;      
    else
        % If only one side of downstream turbine falls outside of wake,
        % calculate the area of shadowing
        d = abs(h);
        r = Radii(2);
        R = Radii(1) + kw*x;
        A0 = (r^2)*acos( (d^2 + r^2 - R^2) / (2*d*r) ) + ...
             (R^2)*acos( (d^2 + R^2 - r^2) / (2*d*R) ) - ...
             0.5*sqrt( (-d + r + R)*(d + r - R)*(d - r + R)*(d + r + R));
    end

else
    % If all the downstream rotor is within the wake, area of shadowing is
    % the area of downstream rotar
    A0 = pi*Radii(2)^2; 
end

end