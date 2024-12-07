# Wind Turbine Design and Optimization  

This repository contains a collection of projects focused on the optimization of wind turbine blades and wind turbine farms using advanced computational techniques. By leveraging genetic algorithms, radial basis function modeling, and aerodynamic theory, the codebase aims to maximize the efficiency and performance of wind energy systems.  

---

## Features  

### 1. **Turbine Blade Optimization**  
- Implements a **genetic algorithm (GA)** to optimize key parameters of wind turbine blades, including twist distribution, chord length, and tip speed ratio (TSR).  
- Incorporates Betz's theory and exponential parameterization to maximize the coefficient of power (C\_P).  
- **Files**:  
  - `newerMain.m` / `newestMain.m`: Main scripts for the blade optimization genetic algorithm.  

### 2. **Turbine Farm Optimization**  
- A genetic algorithm to configure wind turbine farms for optimal placement and energy yield.  
- Includes algorithms to evaluate inter-turbine interference and maximize overall efficiency.  
- **File**:  
  - `Turbine Farm Genetic Algorithm.m`: Main GA script for wind turbine farm optimization.  

### 3. **Blackbox Function Modeling with Radial Basis Functions**  
- A **radial basis function (RBF)** model to approximate the outputs of a blackbox simulation.  
- Allows for faster optimization by providing a surrogate model of the complex blackbox evaluations.  
- **Files**:  
  - `Blackbox Radial Basis Function.m`: RBF implementation.  
  - `Radial Basis Function to estimate blackbox.m`: Estimation script for blackbox modeling.  

---

## Documentation  

### Reports  
- **aeem20_individual_report.pdf**: A comprehensive individual report on turbine blade optimization, including methodology and results.  
- **team3_report_final.pdf**: A detailed team report covering blackbox modeling and wind farm optimization projects.  

---

## Installation and Usage  

1. Clone this repository:  
   ```bash  
   git clone https://github.com/your-username/repo-name.git  
