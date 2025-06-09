# Optimised Planning of Train Routing at Copenhagen Central Station

This project presents an extended set-packing model, developed in Julia with the Gurobi solver, to optimize train platforming and routing at Copenhagen Central Station during peak hours. It aims to minimize delays and improve scheduling efficiency by automating the complex task of guiding trains through the station.

## Table of Contents
- [Authors](#authors)
- [About The Project](#about-the-project)
- [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Limitations](#limitations)

## Authors

-   **Caroline Hørlykke** - BSc Data Science and Management, DTU
-   **Emilie Grønborg Kristensen** - BSc Data Science and Management, DTU

## About The Project

As the largest and busiest train station in Denmark, Copenhagen Central Station faces significant challenges in managing high volumes of train traffic, particularly during the morning rush hour. Traditional manual scheduling is often slow and inflexible in response to real-time events.

This project addresses these challenges by developing a optimization model to handle platform allocation and the associated arrival and departure routing for regional and long-distance trains. The model is built upon a **Mixed-Integer Programming (MIP)** framework, specifically an extended Set Packing Problem formulation. It uses real-world train schedule data from 2022 and 2023, kindly provided by DSB.

The core of the model is an objective function where costs are strategically assigned to reflect operational priorities. This allows the model to find the most efficient schedules while respecting critical railway rules, including:

-   Enforcing a 3-minute minimum headway between trains.
-   Limiting the use of specific platforms for certain trains.
-   Prioritizing direct, non-conflicting paths.
-   Incorporating realistic traversal times based on geographical data and train speeds.
-   Enabling sectional release of track junctions for more granular control.

The model successfully generated schedules that comply with all operational rules and station-specific conditions, demonstrating the high potential of optimization-based approaches for improving railway efficiency.

### Built With

The project relies on the following technologies and packages:

**Core:**
-   [Julia (v1.8.5)](https://julialang.org/)
-   [Gurobi Optimizer](https://www.gurobi.com/)

**Julia Packages:**
-   [JuMP.jl](https://jump.dev/)
-   [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl)
-   [DataFrames.jl](https://dataframes.juliadata.org/stable/)
-   [CSV.jl](https://github.com/JuliaData/CSV.jl)
-   [XLSX.jl](https://github.com/felipenoris/XLSX.jl)
-   [Dates](https://docs.julialang.org/en/v1/stdlib/Dates/)
-   [SparseArrays](https://docs.julialang.org/en/v1/stdlib/SparseArrays/)
-   [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl)
-   [Statistics](https://docs.julialang.org/en/v1/stdlib/Statistics/)

**Supporting Scripts:**
-   [Python (v3.10.12)](https://www.python.org/) (for visualization)
-   [Pandas](https://pandas.pydata.org/)
-   [Plotly](https://plotly.com/python/)
-   [NumPy](https://numpy.org/)
-   [Matplotlib](https://matplotlib.org/)

---

## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

1.  **Julia:** Ensure you have Julia v1.8.5 or a compatible version installed. You can download it [here](https://julialang.org/downloads/).
2.  **Gurobi:** This model requires the Gurobi Optimizer. A free academic license is sufficient and can be obtained from the [Gurobi website](https://www.gurobi.com/academia/academic-program-and-licenses/).
3.  **Git:** You will need Git to clone the repository.
4.  **Python:** Python v3.10.12 or newer is required to run the visualization scripts.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/[your-github-username]/[your-repo-name].git
    cd [your-repo-name]
    ```

2.  **Add Input Data:**
    This model requires input data (train schedules) provided by DSB. You must place the train schedules as .xlxs files in the project directory.

3.  **Install Julia Packages:**
    Open a Julia REPL in the project's root directory and run the following commands to install all the required packages.
    ```julia
    using Pkg
    Pkg.activate(".")
    Pkg.instantiate()
    ```

4.  **Install Python Packages:**
    It is recommended to create a Python virtual environment. From the project's root directory, install the necessary packages.
    ```sh
    pip install pandas matplotlib
    ```

## Usage

The process involves manually configuring the desired model across several files, running the optimization in Julia, and then using a Python script to visualize the output. **All commands should be run from the root directory of the project.**

### Step 1: Configure and Run the Optimization Model

The project contains three different model variations. Running a specific model is a manual process that requires editing several source files. Follow these steps carefully:

1.  **Primary Model Selection (`main.jl`):**
    Open `src/main.jl`. This file acts as the main entry point. Look for comments that instruct you on which lines to comment or uncomment to choose between running **Model 3** or the **Model 1/2** family.

2.  **Parameter and Logic Tuning (`optimization.jl`):**
    Open `src/optimization.jl`. This file contains key parameters and logic for the optimization. You may need to adjust settings here based on the instructions found in the comments, depending on which model you selected in the previous step.

3.  **Choosing Between Model 1 and Model 2 (`model_1and2.jl`):**
    If you configured the project to run the Model 1/2 family, you must explicitly choose between them. Open `src/model_1and2.jl`. Inside this file, you will find specific instructions on how to comment/uncomment lines to activate either **Model 1** or **Model 2**.

4.  **Execute the Main Script:**
    Once you have configured the files for your desired model, run the script from your project's root directory:
    ```sh
    julia src/main.jl
    ```
    This will execute the chosen optimization model. Upon completion, it will generate a results CSV file containing the optimized train schedule.

### Step 2: Visualize the Schedule

After the CSV file has been generated, you can create a swimlane diagram to visualize the train routes and timings.

1.  **Run the Swimlane Generator:**
    From the root directory, run:
    ```sh
    python3 src/swimlane_generator.py
    ```
    This script will read the output CSV file and generate a plot, saving it as an image file (e.g., `swimlanes.png`).

## Project Structure
```
.

├── src/                   # All source code
│   ├── data/                  # (Must be created manually for input data)
│   ├── main.jl                # Main script to run the optimization
│   ├── optimization.jl        # Core functions for the optimization model
│   ├── model_1and2.jl         # Implementation of Model 1 and Model 2
│   ├── model_3.jl             # Implementation of Model 3
│   ├── graph.jl               # Helper functions for the graph network
│   ├── swimlane_generator.py  # Python script to generate swimlane plots
│   ├── headway_comparison.py  # Supporting script for headway analysis
│   ├── path_lengths_histogram.jl # Supporting script for path length histograms
│   └── README.md
└── 
```

## Limitations

-   **Station Specificity:** The model's track data, rules, and logic are hard-coded for Copenhagen Central Station. It is not compatible with other railway stations without significant modification.
-   **Coarse Track Sections:** The classification of track sections is relatively coarse, which may limit the number of feasible paths identified by the model.
-   **No Train Splitting:** The current model does not have the capability to handle train splitting or joining operations.

