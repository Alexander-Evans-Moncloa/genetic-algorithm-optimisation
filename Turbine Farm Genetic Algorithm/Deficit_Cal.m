function Deficit = Deficit_Cal(Position, Radius, Height)
% This function calculates the deficit using input of position, radius and
% height

% For testing
% clear
% Position = linspace(0,2000,8);
% Height = [100 100 100 100 100 100 100 100];
% Radius = [40 40 40 40 40 40 40 40];

% Calculating the difference between position and height points 
Diff_Position = diff(Position);
Diff_Height = diff(Height);

% Priming variables
Total_Deficit = zeros(size(Diff_Position));

% Calculating the total deficit for all of the turbines
for count1 = 1:length(Diff_Position)
    Sq_Deficit = 0;

    % Calculating the total deficit for the specifide turbine
    for count2 = 1:count1
        % Calculating the individual deficit for the specified turbine
        Ind_Deficit = JensenWake(sum(Diff_Position(count2:count1)), sum(Diff_Height(count2:count1)),...
            [Radius(count2) Radius(count1)]);

        % Adding each individual deficit for the specified turbine
        Sq_Deficit = Sq_Deficit + Ind_Deficit^2;
    end
    Total_Deficit(count1) = sqrt(Sq_Deficit);
end

% Putting the list of deficit together
Deficit = [0 Total_Deficit];
% disp(Deficit)

end

%% 
function Ind_Deficit = JensenWake(Diff_Position, Diff_Height, Comp_Radius)
% Calcualtes the velocity deficit induced from an upstream turbine using
% the Jensen Wake model

% Parameters
kw = 0.06; % The wake expansion factor
Ct = 0.75; % Coefficient of thrust

% Calculate partial shadow effect (if any)
A0 = Shadow_Cal(Diff_Position, Diff_Height, kw, Comp_Radius);

% Calculate deficit
Ind_Deficit = ((1 - sqrt(1-Ct)) ./ ((1 + kw * Diff_Position / Comp_Radius(1)) .^2)) ...
    *(A0/(pi*Comp_Radius(2)^2)); %if no partial shadowing, R0/R = 1;

end