function [Total_AEP, Ind_AEP] = AEP_Cal(Deficit, Radius)
% This function is used to calculate the total and individual annual energy production
% from the turbines using the Weibull distribution, power model and velocity deficit

% For testing
% clear
% Radius = [40 40 40 40 40 40 40 40];
% Deficit = [0 0.2450 0.2847 0.3003 0.3079 0.3120 0.3145 0.3160];

% Parameters
% Weibull shape facto.rs
k = 2.2;
c = 5;
% Turbine efficiency
Turb_eff = 0.9;

% Calculating variables
Speed_cut_in = 0.044 .* Radius + 0.778; % m/s
Speed_rated = 0.133 .* Radius + 5.33; % m/s
Speed_cut_out = 0.222 .* Radius + 13.89; % m/s
Power_rated = 0.243 .* Radius .^ 2.23; % kW
Turb_num = size(Radius,2);
Deficit_ind = 1 ./ (1 - Deficit); % deficit of the wind speed 

% Priming variables
Power_prob_initial = zeros(1,Turb_num);
Power_prob_rated = zeros(1,Turb_num);

for count1 = 1:1:Turb_num
    % Calculate the power of probability between cut in speed and rated speed
    fun_initial = @(v) Deficit_ind(count1) * Power_rated(count1) * (v ./ Speed_rated(count1)).^3 ...
        .* k./c .* (Deficit_ind(count1) .*v./c).^(k-1) .* exp(-(Deficit_ind(count1) .*v./c).^k);
    Power_prob_initial(count1) = integral(fun_initial, Speed_cut_in(count1), Speed_rated(count1));

    % Calculate the power of probability between rated speed and cut off speed
    fun_rated = @(v) Deficit_ind(count1) *Power_rated(count1) ...
        .* k./c .* (Deficit_ind(count1) .*v./c).^(k-1) .* exp(-(Deficit_ind(count1) .*v./c).^k);
    Power_prob_rated(count1) = integral(fun_rated, Speed_rated(count1), Speed_cut_out(count1));
end

% Calculate the individual and total annual energy production
Ind_AEP = Turb_eff * 8760 * (Power_prob_initial + Power_prob_rated); %kWh
Total_AEP = sum(Ind_AEP); %kWh

% disp(Ind_AEP)
% disp(Total_AEP)
