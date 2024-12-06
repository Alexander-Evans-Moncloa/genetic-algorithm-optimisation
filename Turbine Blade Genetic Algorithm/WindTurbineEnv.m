classdef WindTurbineEnv < rl.env.MATLABEnvironment
    properties
        % Number of aerodynamic stations (e.g., 25)
        NumStations = 25;

        % Current state: twist and chord lengths
        CurrentTwist;
        CurrentChord;

        % Simulation parameters (passed from the initialisation script)
        Params;
    end

    properties (Access = private)
        % Maximum and minimum allowable values for twist and chord
        MaxTwist = 30; % degrees
        MinTwist = 0; % degrees
        MaxChord = 1.0; % meters
        MinChord = 0.1; % meters
    end

    methods
        function this = WindTurbineEnv(params)
            % Define Observation and Action space
            obsInfo = rlNumericSpec([50 1]); % 25 twist + 25 chord values
            actInfo = rlNumericSpec([2 1], 'LowerLimit', -0.1, 'UpperLimit', 0.1);
            
            % Call superclass constructor FIRST
            this@rl.env.MATLABEnvironment(obsInfo, actInfo);

            % Now assign other properties
            this.Params = params;

            % Reset the environment state
            reset(this);
        end

        function obs = getObservation(this)
            % Combine twist and chord into a single observation vector
            obs = [this.CurrentTwist; this.CurrentChord];
        end

        function [nextObs, reward, isDone, loggedSignals] = step(this, action)
            % Apply action to modify twist and chord
            % Action is [Δtwist, Δchord]
            deltaTwist = action(1);
            deltaChord = action(2);

            % Update twist and chord within allowed bounds
            this.CurrentTwist = max(min(this.CurrentTwist + deltaTwist, this.MaxTwist), this.MinTwist);
            this.CurrentChord = max(min(this.CurrentChord + deltaChord, this.MaxChord), this.MinChord);

            % Run the simulation with the updated parameters
            newTwist = ones(this.NumStations, 1) * this.CurrentTwist;
            newChord = ones(this.NumStations, 1) * this.CurrentChord;
            Foils = {'S826'}; % Example aerofoil
            foilsDist = ones(1, this.NumStations);
            numBlades = 3;

            % Call simulation function
            [rotor, ~] = runSIM(this.Params, newTwist, newChord, Foils, foilsDist, numBlades);

            % Calculate reward as negative Cp (minimisation problem)
            [maxCp, ~] = max(rotor.CP); % Extract maximum Cp
            reward = -maxCp;

            % Get the next observation
            nextObs = this.getObservation();

            % Episode termination condition (e.g., max steps reached)
            isDone = false; % Modify if needed (e.g., based on constraints)

            % Logged signals for debugging
            loggedSignals = [];
        end

        function reset(this)
            % Reset twist and chord to initial values
            this.CurrentTwist = 10; % Example initial twist
            this.CurrentChord = 0.2; % Example initial chord
        end
    end
end
