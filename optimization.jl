using Pkg
using DataStructures


module optimization
using DataFrames
using XLSX
using JuMP
using Gurobi
using CSV
using Dates
using SparseArrays

export set_packing, id_op_path, create_csv

function set_packing(T::Matrix{Int8}, R::Matrix{Int8}, omega::Vector{Any})
    #Convert T and R to sparse matrices
    T = sparse(T)
    R = sparse(R)
    
    #Number of trains, paths, and resources
    num_trains = size(T, 1)
    num_paths = size(T, 2)
    num_resources = size(R, 1)
    #MODEL 1+2
    punishment = [o[7] for o in omega]
   #= #MODEL 3
    punishment = [o[11] for o in omega]=#
    

    # Create a model
    model = Model(Gurobi.Optimizer)
    # set_optimizer_attribute(model, "Presolve", 0)  # Disable presolve
    # set_optimizer_attribute(model, "Heuristics", 0)  # Reduce heuristics

    # Define the binary decision variable x
    @variable(model, x[1:num_paths], Bin)

    # Objective function: minimize the sum of punishments for selected paths
    @objective(model, Min, punishment' * x)

    # Constraint: each resource can be used by at most one path
    @constraint(model, R * x .<= 1)  # Note the dot (.) for broadcasting

    # Constraint: each train must have exactly one path
    @constraint(model, T * x .== 1)


    # Solve the model
    optimize!(model)

    # Check the status of the solution
    status = termination_status(model)
    if status == MOI.OPTIMAL

        # Get the values of x as a vector
        x_values = convert(Vector{Int8}, round.(value.(x)))
       
        return x_values  # Return the selected paths
    else
        println("No optimal solution found. Status: ", status)
        return nothing  # Return nothing if no solution is found
    end
end



function id_op_path(T::Matrix{Int8}, op_sol::Vector{Int8}, Omega::Vector{Any})
    num_trains = size(T, 1)
    num_paths = size(T, 2)

    #isolate the paths from omega
    path_set = [i[2] for i in Omega]
    t_id_set = [i[1] for i in Omega]

    #MODEL 1+2
    platform_set = [i[4] for i in Omega]

   #= #MODEL 3
    platform_set = [i[6] for i in Omega] =#

    #result matrix
    results = Matrix{Any}(undef, num_trains, 3)
    println("Selected columns for each row in T:")
    for i in 1:num_trains
        # Find the column index where x[j] == 1 for the current row
        selected_column = findfirst(j -> T[i, j] == 1 && op_sol[j] == 1, 1:num_paths)
        #println(selected_column)
        
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
    return results
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

