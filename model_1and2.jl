using Pkg
using DataStructures

module model_1and2
using DataFrames
using XLSX
using Dates
using SparseArrays
export printpath, find_all_jcts, not_visited, find_paths, find_trains, omega, set_S, mat_R, train_time_mapping, mat_T, allocate_t_src, allocate_t_dst

#Finds trains to Nørreport
function find_trains(filename::String="Ophold på Kh - Onsdag 2022 1.xlsx") 
    df = XLSX.readxlsx(filename)
        
    if filename == "Ophold_Kh.xlsx"
        sheet = df["Data"]
    elseif filename == "Ophold på Kh - Onsdag 2022 1.xlsx"
        sheet = df["FInal result"]
    end
        
    data = sheet["B2:J"*string(size(sheet[:], 1))] 
    to_matrix = Matrix(data) # Ensures row-wise structure
        
    # Handle missing values in column 1 and column 2
    for i in 1:size(to_matrix, 1)  # Loop through each row
        if ismissing(to_matrix[i, 1])  # Check if column 1 is missing
            to_matrix[i, 1] = to_matrix[i, 5]  # Replace with column 5
        end
        if ismissing(to_matrix[i, 2])  # Check if column 2 is missing
            to_matrix[i, 2] = to_matrix[i, 6]  # Replace with column 6
        end
        if ismissing(to_matrix[i, 3])
            # Subtract column 9 from column 7 (DateTime format)
            to_matrix[i, 3] = to_matrix[i, 7] - Dates.Minute(to_matrix[i, 9])
        end
        if ismissing(to_matrix[i, 4])
            to_matrix[i, 4] = "Workshop"
        end
        if ismissing(to_matrix[i, 5])  
            to_matrix[i, 5] = to_matrix[i, 1]  
        end
        if ismissing(to_matrix[i, 6])  # Check if column 2 is missing
            to_matrix[i, 6] = to_matrix[i, 2]  # Replace with column 6
        end
        if ismissing(to_matrix[i, 7])
            # Subtract column 9 from column 7 (DateTime format)
            to_matrix[i, 7] = to_matrix[i, 3] + Dates.Minute(to_matrix[i, 9])
        end
        if ismissing(to_matrix[i, 8])
            to_matrix[i, 8] = "Workshop"
        end
        # Replace both values with "col2col6"
        # Check if values in column 2 and column 6 are the same
        if to_matrix[i, 2] != to_matrix[i, 6]
            new_value = parse(Int, string(to_matrix[i, 2]) * string(to_matrix[i, 6]))
            to_matrix[i, 2] = new_value
            to_matrix[i, 6] = new_value
        end

    end
  
    cleaned_df = to_matrix
    
    return cleaned_df
end


#Function linking all possible paths for each train to a train id
function omega(g_to::Tuple{Vector{Vector{Int}}, Int}, g_from::Tuple{Vector{Vector{Int}}, Int}, g_to_w::Tuple{Vector{Vector{Int}}, Int}, g_from_w::Tuple{Vector{Vector{Int}}, Int}, v::Int, df::Matrix{Any})
    t_src_to = allocate_t_src(df)
    t_dst_from = allocate_t_dst(df)
    
    to_graph = g_to[1]
    from_graph = g_from[1]
    to_w_graph = g_to_w[1]
    from_w_graph = g_from_w[1]

    #Create ingoing possible paths with train ids
    to_set = []

    for i in 1:size(df, 1)
        train_id = df[i, 2]  # train_id is in column 2
        for dst_platform in 1:9  # All 9 platforms as possible destinations
            if dst_platform == 9 && (df[i, 1] in ["IL", "L"] || df[i, 5] in ["IL", "L"])
                continue
            end
            if t_src_to[i][2] == 59
                paths_to = find_paths(to_w_graph, t_src_to[i][2], dst_platform, v)
                for path in paths_to
                    push!(to_set, (train_id, path, dst_platform))
                end
            else
                paths_to = find_paths(to_graph, t_src_to[i][2], dst_platform, v)
                for path in paths_to
                    push!(to_set, (train_id, path, dst_platform))
                end
            end
        end
    end
    
    #Create outgoing possible paths with train ids
    from_set = []
    for i in 1:size(df, 1)
        train_id = df[i, 2]  # train_id is in column 2
        for src_platform in 1:9  # All 9 platforms as possible sources
            if src_platform == 9 && (df[i, 1] in ["IL", "L"] || df[i, 5] in ["IL", "L"])
                continue
            end
            if t_dst_from[i][2] == 59
                
                paths_to = find_paths(from_w_graph, src_platform, t_dst_from[i][2], v)
                for path in paths_to
                    push!(from_set, (train_id, path, src_platform))
                end
            else
                paths_from = find_paths(from_graph, src_platform, t_dst_from[i][2], v)
                for path in paths_from
                    push!(from_set, (train_id, path, src_platform))
                end
            end
        end
    end
 

    #Combine the paths to make one path from src to dst
    combined_paths = []
     for (train_id_to, path_to, dst_platform) in to_set
         for (train_id_from, path_from, src_platform) in from_set
             if train_id_to == train_id_from && dst_platform == src_platform
                 combined_path = vcat(path_to, path_from[2:end])  # Avoid duplicating the platform
                 push!(combined_paths, (train_id_to, combined_path, path_to[1:end-1], path_to[end], path_from[2:end]))
             end
         end
     end     

    # Create expanded Omega with block durations (3-7 minutes)
    expanded_omega = []

    for omega in combined_paths
        train_id = omega[1]
        combined_paths = omega[2]
        path_to = omega[3]
        platform = omega[4]
        path_from = omega[5]

        #MODEL 1
        for buffer in 3:10
            punishment = exp(-4/5*buffer)*10000

           #MODEL 2
            if platform == 9
                punishment += 200
            end
            # Punishment for the path length
            punishment += 5 * length(combined_paths)

            push!(expanded_omega, (train_id, combined_paths, path_to, platform, path_from, buffer, punishment))
        end
    end
    
    #Create NULL paths
    null_array = []
    
    combined_paths = []
    path_to = []
    platform = []
    path_from = []
    buffer = 0
    punishment = 10000

    for i in 1:size(df, 1)
        train_id = df[i, 2]
        push!(null_array, (train_id, combined_paths, path_to, platform, path_from, buffer, punishment))
    end

    final_omega = vcat(null_array, expanded_omega)

    return final_omega
end

function find_all_jcts(g::Tuple{Vector{Vector{Int64}}, Int64})
    nodes = Set{Int}()  # Use a Set to store unique nodes
    graph = g[1]

    # Iterate through adjacency list
    for (node, neighbors) in enumerate(graph)
        if !isempty(neighbors)  # If the node has neighbors, it's part of the graph
            push!(nodes, node)
            for neighbor in neighbors
                push!(nodes, neighbor)
            end
        end
    end

    return sort(collect(nodes))  # Convert the Set to a sorted Vector
end

#function linking junction to minute
function set_S(g_to::Tuple{Vector{Vector{Int64}}, Int64}, g_from::Tuple{Vector{Vector{Int64}}, Int64}, df::Matrix{Any})
        #Find min and max times in data set  
        min_time = minimum(df[:,3])
        max_time = maximum(df[:,7])
        #Generate all minutes between min and max
        cur = min_time - Dates.Minute(2)
        min_count = []

        while cur <= (max_time + Dates.Minute(3))
            push!(min_count, cur)
            cur += Dates.Minute(1)
        end

    
    #Find all junctions in a graph
    jcts_to = find_all_jcts(g_to)
    jcts_from = find_all_jcts(g_from)
    jcts = unique(vcat(jcts_from, jcts_to))
    

    #Combine junction with minute
    s = []
    for i in 1:length(jcts)
        for j in 1:length(min_count)
            s = push!(s, [jcts[i], min_count[j]])
        end
    end
    #println(s)
    return(s)
end


function train_time_mapping(df::Matrix{Any})
    
    train_time_map = Dict{Int, Tuple{Dates.Time, Dates.Time}}()

    for i in 1:size(df, 1)
        train_id = df[i, 2]  
        departure_time = df[i, 7]
        arrival_time = df[i, 3]

        # Store both times in the dictionary
        train_time_map[train_id] = (arrival_time, departure_time)
    end

    return train_time_map
end




function mat_R(S::Vector{Any}, omega::Vector{Any}, df::Matrix{Any})
    # Initialize matrix with correct dimensions
    init_m = zeros(Int8, length(S), length(omega))
    
    # Create train time mapping
    train_time_map = train_time_mapping(df)
    
    # Process each train-path-duration combination (columns)
    for (c, omega_exp) in enumerate(omega)
        train_id, path, path_to, platform, path_from, block_duration, punishment = omega_exp
        
        # Get train times
        ar_time = train_time_map[train_id][1]
        dep_time = train_time_map[train_id][2]
        
        # Calculate extended platform occupation period
        platform_start = ar_time
        platform_end = dep_time + Dates.Minute(block_duration)
        
        # Process each platform-time combination (rows)
        for (r, (jct, time)) in enumerate(S)
            # If junction is in path to platform
            if jct in path_to
                if ar_time - Dates.Minute(3) <= time < ar_time 
                    init_m[r, c] = 1
                end
            end 

            # If junction is the platform
            if jct == platform
                if platform_start <= time < platform_end
                    init_m[r, c] = 1
                end
            end

            # If junction is in path from platform
            if jct in path_from
                if dep_time <= time <= dep_time + Dates.Minute(2)
                    init_m[r, c] = 1
                end
            end
        end
    end
     
    # Return both the matrix and column info for reference
    return  init_m
end


function mat_T(Omega::Vector{Any}, df::Matrix{Any})
    
    train_ids = df[:, 2]
    

    #initialize matrix
    init_m = zeros(Int8, length(train_ids), length(Omega))

    #Assign 1 if train_id is same in column and omega
    for i in 1:length(train_ids)
        for j in 1:length(Omega)
            if train_ids[i] == Omega[j][1]
                init_m[i,j] = 1
            end
        end
    end

    return init_m
end


#Function for BFS
function not_visited(x::Int, path::Vector{Int})
    size = length(path)
    for i in 1:size
        if (path[i] == x)
            return 0
        end
    end
    return 1
end

function allocate_t_src(df::Matrix{Any})
    t_src = []
    for i in 1:size(df, 1)
        if df[i, 4] == "Nørreport"
            push!(t_src, [df[i,2], 128])
        elseif df[i, 4] == "Valby"
            push!(t_src, [df[i,2], 123])
        elseif df[i, 4] == "Ny Ellebjerg/København Syd"
            push!(t_src, [df[i,2], 121])
        elseif df[i, 4] == "CPH Lufthavn"
            push!(t_src, [df[i,2], 125])
        elseif df[i, 4] == "Workshop"
            push!(t_src, [df[i,2], 59])
        end
    end
    
    return t_src
end 

function allocate_t_dst(df::Matrix{Any})
    t_dst = []
    for i in 1:size(df, 1)
        if df[i, 8] == "Nørreport"
            push!(t_dst, [df[i,6], 127])
        elseif df[i, 8] == "Valby"
            push!(t_dst, [df[i,6], 124])
        elseif df[i, 8] == "Ny Ellebjerg/København Syd"
            push!(t_dst, [df[i,6], 122])
        elseif df[i, 8] == "CPH Lufthavn"
            push!(t_dst, [df[i,6], 126])
        elseif df[i, 8] == "Workshop"
            push!(t_dst, [df[i,6], 59])
        end
    end

    return t_dst

end 

#Find all paths using BFS
function find_paths(g::Vector{Vector{Int}}, src::Int, dst::Int, v::Int) #v = number of vertices in g
    path_count = 1
    path_jcts = []
    for s in src #For every starting point (source)
        for d in dst #For every destination

        #Create queue for path
            q = []

            #Path vector to store the current path
            path = Int[]
            push!(path, s)
            push!(q, copy(path))

            while !isempty(q)
                path = popfirst!(q)
                last = path[length(path)]

                #If last vertex is dst, print path
                if last == d
                    push!(path_jcts, path)
                    path_count += 1
                end

                for i in 1:length(g[last])
                    if not_visited(g[last][i], path) == 1
                        newpath = copy(path)
                        push!(newpath, g[last][i])
                        push!(q, newpath)
                    end
                end
            end
        end
    end
    return(path_jcts)
end

end