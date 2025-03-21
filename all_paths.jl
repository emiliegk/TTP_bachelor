using Pkg
using DataStructures


module All_paths
using DataFrames
using XLSX
using Dates
export printpath, find_all_jcts, not_visited, find_paths, find_trains, omega, set_S, mat_R, train_time_mapping, mat_T, allocate_t_src, allocate_t_dst

#Finds trains to Nørreport
function find_trains() 
    df = XLSX.readxlsx("Ophold_Kh.xlsx")
    sheet = df["Data"]
    data = sheet["B2:J"*string(size(sheet[:], 1))] 
    to_matrix = Matrix(data)  # Ensures row-wise structure
        
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
        # Check if values in column 2 and column 6 are the same
        if to_matrix[i, 2] != to_matrix[i, 6]
            # Replace both values with "col2col6"
            new_value = (to_matrix[i, 2]) *  (to_matrix[i, 6])
            to_matrix[i, 2] = new_value
            to_matrix[i, 6] = new_value
        end

    end
  
    #For now we are only interested in the trains going to Nørreport
    #This has to be changed later!!!!!
    
    cleaned_df = to_matrix[(to_matrix[:, 8] .== "Nørreport") .| (to_matrix[:, 4] .== "Nørreport") , :]
    
    # Corrected code
    cleaned_df = cleaned_df[.!( (cleaned_df[:, 8] .== "Workshop") .| (cleaned_df[:, 8] .== "Ny Ellebjerg/København Syd") .| 
                                (cleaned_df[:, 4] .== "Workshop") .| (cleaned_df[:, 4] .== "Ny Ellebjerg/København Syd") ), :]



   
    

    #when all stations are implemented:
    #cleaned_df =  coalesce.(to_matrix, "")

    #println(to_kn_trains)
   
        
    return cleaned_df
end

#Function linking all possible paths for each train to a train id
function omega(g_to::Tuple{Vector{Vector{Int}}, Int}, g_from::Tuple{Vector{Vector{Int}}, Int}, v::Int, df::Matrix{Any})
    t_src_to = allocate_t_src(g_to, df)
    t_dst_from = allocate_t_dst(g_from, df)

#=
    if g[2] == 1
        trains = df[df[:, 8] .!= "", :]
        train_ids = trains[:, 6]
    elseif g[2] == 2
        trains = df[df[:, 4] .!= "", :]
        train_ids = trains[:, 2]

    end=#
    
    to_graph = g_to[1]
    from_graph = g_from[1]

    #Create ingoing possible paths with train ids
    to_set = []
    for i in 1:size(df, 1)
        train_id = df[i, 2]  # train_id is in column 2
        for dst_platform in 1:8  # All 8 platforms as possible destinations
            paths_to = find_paths(to_graph, t_src_to[i][2], dst_platform, v)
            for path in paths_to
                push!(to_set, (train_id, path, dst_platform))
            end
        end
    end
    
    #Create outgoing possible paths with train ids
    from_set = []
    for i in 1:size(df, 1)
        train_id = df[i, 2]  # train_id is in column 2
        for src_platform in 1:8  # All 8 platforms as possible sources
            paths_from = find_paths(from_graph, src_platform, t_dst_from[i][2], v)
            for path in paths_from
                push!(from_set, (train_id, path, src_platform))
            end
        end
    end
 

    #Combine the paths to make one path from src to dst
    combined_paths = []
    for (train_id_to, path_to, dst_platform) in to_set
        for (train_id_from, path_from, src_platform) in from_set
            if train_id_to == train_id_from && dst_platform == src_platform
                combined_path = vcat(path_to, path_from[2:end])  # Avoid duplicating the platform
                push!(combined_paths, (train_id_to, combined_path))
            end
        end
    end

    return combined_paths
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

        while cur <= (max_time + Dates.Minute(2))
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


function train_time_mapping(df::Matrix{Any}, g_to::Tuple{Vector{Vector{Int64}}, Int64}, g_from::Tuple{Vector{Vector{Int64}}, Int64})
    
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


function mat_R(S::Vector{Any}, Omega::Vector{Any}, df::Matrix{Any}, g_to::Tuple{Vector{Vector{Int64}}, Int64}, g_from::Tuple{Vector{Vector{Int64}}, Int64})
    #Initialize matrix 
    init_m = zeros(Int, length(S), length(Omega))

    #isolate the paths from omega
    path_set = [i[2] for i in Omega] # Convert the Set back to a Vector

    #Create mapping btw train id and departure time
    train_time_map = train_time_mapping(df, g_to, g_from)
    
    #Extract the junction from set_S
    jct_set = [j[1] for j in S]
    time_set = [j[2] for j in S]


    for r in 1:length(S)
        time = time_set[r] 
        for c in 1:length(Omega)
            train_id = Omega[c][1] #Find train ID for train
            #print statement
            move_time = train_time_map[train_id] #Look up the departure time for that train
            
                       
            #If a junction is in a path at a given time, change 0 to 1
            if jct_set[r] in path_set[c] 
                #=
                println(move_time)
                println(time)
                println("")
                =#
                    #Currently, the junctions used by the trains are blocked for 3 minutes (departure time + 2 min)
                    if (move_time <= time <= move_time + Dates.Minute(2) ) && graph[2] == 1
                        init_m[r, c] = 1
                    elseif (move_time - Dates.Minute(2) <= time <= move_time ) && graph[2] == 2
                        init_m[r, c] = 1
                        #

                    end
            end
        end
    end
    #=
    count = 0
    for i in 1:length(S)
        if jct_set[i] != count
            count = jct_set[i]
            println("")
            println("----------------------------------")
            println("Track ", count)
            println("----------------------------------")
        end
        print(init_m[i,1])
            
    end 
    
    =#
    return init_m
end


function mat_T(Omega::Vector{Any}, df::Matrix{Any})
    
    train_ids = df[:, 2]
    

    #initialize matrix
    init_m = zeros(Int, length(train_ids), length(Omega))

    #Assign 1 if train_id is same in column and omega
    for i in 1:length(train_ids)
        for j in 1:length(Omega)
            if train_ids[i] == Omega[j][1]
                init_m[i,j] = 1
            end
        end
    end
    
    #=
    count = 0
    for value in Iterators.flatten(eachrow(init_m))  # Flatten the matrix row-wise
        print(value, " ")  # Print each number with a space
        count += 1
        if count % (5522)== 0  # Insert a newline every 33 numbers
            println("")
            println("")
        end
    end=#
    

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

function allocate_t_src(g::Tuple{Vector{Vector{Int64}}, Int64}, df::Matrix{Any})
    t_src = []
    if g[2] == 1 #If from_kh
        for i in 1:size(df, 1)
            push!(t_src, [df[i,6], i%8 + 1])
        end
    elseif g[2] == 2 #if to_kh
        for i in 1:size(df, 1)
            if df[i, 4] == "Nørreport"
                push!(t_src, [df[i,2], 128])
            elseif df[i, 4] == "Valby"
                push!(t_src, [df[i,2], 123])
            elseif df[i, 4] == "Ny Ellebjerg/København Syd"
                push!(t_src, [df[i,2], 121])
            elseif df[i, 4] == "CPH Lufthavn"
                push!(t_src, [df[i,2], 125])
            end
        end
    end

    
    return t_src
end 

function allocate_t_dst(g::Tuple{Vector{Vector{Int64}}, Int64}, df::Matrix{Any})
    t_dst = []
    if g[2] == 2 #If to_kh
        for i in 1:size(df, 1)
            push!(t_dst, [df[i,2], i%8 + 1])
        end
    elseif g[2] == 1 #if from_kh
        for i in 1:size(df, 1)
            if df[i, 8] == "Nørreport"
                push!(t_dst, [df[i,6], 127])
            elseif df[i, 8] == "Valby"
                push!(t_dst, [df[i,6], 124])
            elseif df[i, 8] == "Ny Ellebjerg/København Syd"
                push!(t_dst, [df[i,6], 122])
            elseif df[i, 8] == "CPH Lufthavn"
                push!(t_dst, [df[i,6], 126])
            end
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
            #println("")
            #print("Paths from platform $(s) to platform $(d): ")
        
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
                    #println("")
                    #print("Path ", path_count, ": " )
                    #printpath(path_jcts[path_count])
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
            #println("")
            #print("----------------")
        end
    end
    #println("")
    return(path_jcts)
end

end