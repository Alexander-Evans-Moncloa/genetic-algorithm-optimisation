function Total_Rotar_Cost = Rotar_Cost_Cal(Radius)
% This is a costing model for wind turbine farms using the list of rotar radius 

% Parameters
% Cost per turbine constants
A = 7.5;
b = 2.5;

% For testing
% Radius = [40 40 40 40 40 40 50 50];

% Priming variables
Unique_Radius = unique(Radius); % finding all unique rotar radius
Unique_Count = zeros(size(Unique_Radius));
Unique_Cost = zeros(size(Unique_Radius));

% Calculating cost for every unique rotar radius 
for count1 = 1:1:size(Unique_Radius,2)
    % Find the number of wind turbines that has the same rotar radius
    Unique_Count(count1) = sum(Radius == Unique_Radius(count1));

    % Calculating the cost to produce all of the wind turbines with the same rotar radius
    Unique_Cost(count1) = Unique_Count(count1) * (2/3 + 1/3 * exp(-0.017 * Unique_Count(count1) ^2)) * A * Unique_Radius(count1) ^b;
end

% Adding all of the cost of every unique rotar radius
Total_Rotar_Cost = sum(Unique_Cost);
% disp(Total_Rotar_Cost)