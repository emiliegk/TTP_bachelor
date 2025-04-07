using Pkg
using DataStructures



module optimization
using DataFrames
using XLSX
using Dates
using JuMP
using GLPK
using CSV
using Dates

#=include("all_paths.jl")
using .All_paths=#

export set_packing, id_op_path, create_csv

function set_packing(T::Matrix{Int8}, R::Matrix{Int8}, omega::Vector{Any})
    #Number of trains, paths, and resources
    num_trains = size(T, 1)
    num_paths = size(T, 2)
    num_resources = size(R, 1)
    punishment = [o[7] for o in omega]

    # Create a model
    model = Model(GLPK.Optimizer)

    # Define the binary decision variable x
    @variable(model, x[1:num_paths], Bin)

    # Objective function: maximize the sum of selected paths (since rho is 1)
    @objective(model, Min, punishment' * x)

     # Constraint: each resource can be used by at most one path
     for s in 1:num_resources
        @constraint(model, sum(R[s, j] * x[j] for j in 1:num_paths) <= 1)
    end

    # Constraint: each train must have exactly one path
    for i in 1:num_trains
        @constraint(model, sum(T[i, j] * x[j] for j in 1:num_paths) == 1)
    end

   

    # Solve the model
    optimize!(model)

    # Check the status of the solution
    status = termination_status(model)
    if status == MOI.OPTIMAL
        #=
        println("Optimal solution found")
        println("Objective value: ", objective_value(model))
        println("Selected paths: ")

        =#
        # Get the values of x as a vector
        x_values = value.(x)
        #=
        # Print the values with a newline after every 23rd value
        for i in 1:length(x_values)
            #print(x_value[i], " ")
            println("Index: $i, Value: $(x_values[i])") 
            #=if i % 23 == 0
                println("")  # Newline after every 23rd value
                println("")  # Extra newline to separate blocks of 23 values
            end=#
        end
        println()  # Final newline to ensure the output ends cleanly
        =#

       
       
        return value.(x)  # Return the selected paths
    else
        println("No optimal solution found. Status: ", status)
        return nothing  # Return nothing if no solution is found
    end
end



function id_op_path(T::Matrix{Int8}, op_sol::Vector{Float64}, Omega::Vector{Any})
    num_trains = size(T, 1)
    num_paths = size(T, 2)

    #isolate the paths from omega
    path_set = [i[2] for i in Omega]
    t_id_set = [i[1] for i in Omega]
    platform_set = [i[4] for i in Omega]

    #result matrix
    results = Matrix{Any}(undef, num_trains, 3)
    println("Selected columns for each row in T:")
    for i in 1:num_trains
        # Find the column index where x[j] == 1 for the current row
        selected_column = findfirst(j -> T[i, j] == 1 && op_sol[j] == 1, 1:num_paths)
        if selected_column !== nothing
            path = path_set[selected_column]
            t_id = t_id_set[selected_column]
            platform = platform_set[selected_column]
            results[i, :] = [t_id, path, platform]
            println("Train $t_id: Path $path is selected on platform $platform")
        else
            println("Row $i: No column selected")
        end
    end
    results
end

function create_csv(df::Matrix{Any}, id_op_path::Matrix{Any})
    # Create a dictionary for quick lookup of train information by ID
    train_dict = Dict{Any, Tuple}()
    for i in 1:size(df, 1)
        train_id = df[i, 2]  # Train ID
        departure_station = df[i, 4]  # Departure station (column 4)
        arrival_station = df[i, 8]  # Arrival station (column 8)
        arrival_time = df[i, 3]
        departure_time = df[i, 7]
        
        # Determine direction
        direction = if (departure_station in ["Workshop", "Nørreport"]) && 
                       !(arrival_station in ["Workshop", "Nørreport"])
            "mod_vest"
        elseif (departure_station in ["Valby", "Ny Ellebjerg/København Syd", "Workshop", "CPH Lufthavn"]) &&
               (arrival_station in ["Workshop", "Nørreport"])
            "mod_kn"
        else
            "vender"
        end
        
        # Add asterisk if Workshop is involved
        marked_id = if "Workshop" in [departure_station, arrival_station]
            string(train_id) * "*"
        else
            string(train_id)
        end
        
        train_dict[train_id] = (marked_id, arrival_time, departure_time, direction)
    end
    
    # Initialize output matrix with columns: id, path, platform, arrival, departure, direction
    output_matrix = Matrix{Any}(undef, size(id_op_path, 1), 6)
    
    for i in 1:size(id_op_path, 1)
        train_id = id_op_path[i, 1]
        path = id_op_path[i, 2]
        platform = id_op_path[i, 3]
        
        if haskey(train_dict, train_id)
            marked_id, arrival, departure, direction = train_dict[train_id]
            output_matrix[i, :] = [marked_id, path, platform, arrival, departure, direction]
        else
            output_matrix[i, :] = [train_id, path, platform, "UNKNOWN", "UNKNOWN", "UNKNOWN"]
        end
    end
    
    # Convert to DataFrame with column names
    result_df = DataFrame(output_matrix, [:train_id, :path, :platform, :arrival_time, :departure_time, :direction])
    
    # Write to CSV file
    CSV.write("train_schedule_with_paths.csv", result_df)
    
    return result_df
end
        
end

