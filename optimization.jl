using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
#Pkg.add("XLSX")
#Pkg.add("Dates")
using DataStructures
#Pkg.add("DataFrames")


module optimization
using DataFrames
using XLSX
using Dates
using JuMP
using GLPK

#=include("all_paths.jl")
using .All_paths=#

export set_packing

function set_packing(T::Matrix{Int64}, R::Matrix{Int64})
    #Number of trains, paths, and resources
    num_trains = size(T, 1)
    num_paths = size(T, 2)
    num_resources = size(R, 1)

    # Create a model
    model = Model(GLPK.Optimizer)

    # Define the binary decision variable x
    @variable(model, x[1:num_paths], Bin)

    # Objective function: maximize the sum of selected paths (since rho is 1)
    @objective(model, Max, sum(x))

    # Constraint: each train must have exactly one path
    for i in 1:num_trains
        @constraint(model, sum(T[i, j] * x[j] for j in 1:num_paths) == 1)
    end

    # Constraint: each resource can be used by at most one path
    for s in 1:num_resources
        @constraint(model, sum(R[s, j] * x[j] for j in 1:num_paths) <= 1)
    end

    # Solve the model
    optimize!(model)

    # Check the status of the solution
    status = termination_status(model)
    if status == MOI.OPTIMAL
        println("Optimal solution found")
        println("Objective value: ", objective_value(model))
        println("Selected paths: ")

        #=
        # Get the values of x as a vector
        x_values = value.(x)

        # Print the values with a newline after every 23rd value
        for i in 1:length(x_values)
            #print(x_value[i], " ")
            println("Index: $i, Value: $(x_values[i])") 
            if i % 23 == 0
                println("hello")
                println("")  # Newline after every 23rd value
                println("")  # Extra newline to separate blocks of 23 values
            end
        end
        println()  # Final newline to ensure the output ends cleanly

=#

        return value.(x)  # Return the selected paths
    else
        println("No optimal solution found. Status: ", status)
        return nothing  # Return nothing if no solution is found
    end
end
        
end
