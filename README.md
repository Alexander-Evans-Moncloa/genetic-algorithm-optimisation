# Wind Turbine Design and Optimisation  

This repository contains a collection of projects focused on the optimisation of wind turbine blades and wind turbine farms using advanced computational techniques. By leveraging genetic algorithms, radial basis function modeling, and aerodynamic theory, the codebase aims to maximise the efficiency and performance of wind energy systems.  

---

## Features  

### 1. **Turbine Blade Optimisation**  
- Implements a **genetic algorithm (GA)** to optimise key parameters of wind turbine blades, including twist distribution, chord length, and tip speed ratio (TSR).  
- Incorporates Betz's theory and exponential parameterisation to maximise the coefficient of power (Cp).  
- **Files**:  
  - `newerMain.m` / `newestMain.m`: Main scripts for the blade optimisation genetic algorithm.  

### 2. **Turbine Farm Optimisation**  
- A genetic algorithm to configure wind turbine farms for optimal placement and energy yield.  
- Includes algorithms to evaluate inter-turbine interference and maximise overall efficiency.  
- **File**:  
  - `Optimise_Cost_Index.m`: Main GA script for wind turbine farm optimisation.  

### 3. **Blackbox Function Modeling with Radial Basis Functions**  
- A **radial basis function (RBF)** model to approximate the outputs of a blackbox simulation.  
- Allows for faster optimisation by providing a surrogate model of the complex blackbox evaluations.  
- **Files**:  
  - `blackbox.m`: RBF implementation.  
  - `data_sampled_plus_blackbox.m`: Estimation script for blackbox modeling.  

---

## Documentation  

### Reports  
- **aeem20_individual_report.pdf**: A comprehensive individual report on turbine blade optimisation, including methodology and results.  
- **team3_report_final.pdf**: A detailed team report covering blackbox modeling and wind farm optimisation projects.  

---

## Installation and Usage  

1. Clone this repository:  
   ```bash  
   git clone https://github.com/Alexander-Evans-Moncloa/genetic-algorithm-optimisation
