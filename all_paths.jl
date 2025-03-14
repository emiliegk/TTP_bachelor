using Pkg
using DataStructures


module All_paths
using DataFrames
using XLSX
using Dates
export printpath, not_visited, find_paths, find_trains, omega, set_S, mat_R, train_time_mapping, mat_T

#Finds trains to Nørreport
function find_trains()
    df = XLSX.readxlsx("Ophold_Kh.xlsx")
    sheet = df["Data"]
    data = sheet["B2:J"*string(size(sheet[:], 1))] 
    to_matrix = Matrix(data)  # Ensures row-wise structure

    #For now we are only interested in the trains going to Nørreport
    #This has to be changed later!!!!!
    
    
    to_kn_trains = to_matrix[coalesce.(to_matrix[:,8], "") .== "Nørreport", :]
    #println(to_kn_trains)
    

    return to_kn_trains
end

#Function linking all possible paths for each train to a train id
function omega(graph::Vector{Vector{Int}}, src::Vector{Int}, dst::Vector{Int}, v::Int)
    trains = find_trains()
    paths = find_paths(graph, src, dst, v)
    o = Vector{Vector}()
    for i in 1:size(trains,1)
        for j in 1:length(paths)
            push!(o, [paths[j], trains[i, 6], trains[i, ]])
        end
    end
    return o
end

function find_all_jcts(graph::Vector{Vector{Int}})
    nodes = Set{Int}()  # Use a Set to store unique nodes

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

#function linking sporstykke til minuttal
function set_S(graph::Vector{Vector{Int}})
    #Find min and max in minute time table
    df = find_trains()
    
    min_time = minimum(df[:,7])
    max_time = maximum(df[:,7])

    #Generate all minutes between min and max
    cur = min_time
    min_count = []

    while cur <= max_time
        push!(min_count, cur)
        cur += Dates.Minute(1)
    end

    #Find all junctions in a graph
    jcts = find_all_jcts(graph)

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

function train_time_mapping()
    df = find_trains()
    train_time_map = Dict{Int, Dates.Time}()
    for i in 1:size(df, 1)
        train_id = df[i, 6]
        departure_time = df[i,7]
        train_time_map[train_id] = departure_time
    end
    return train_time_map
end

function mat_R(S::Vector{Any}, Omega::Vector{Vector})
    #Initialize matrix 
    init_m = zeros(Int, length(S), length(Omega))

    #isolate the paths from omega
    path_set = [i[1] for i in Omega] # Convert the Set back to a Vector

    #Create mapping btw train id and departure time
    train_time_map = train_time_mapping()
    #Extract the junction from set_S
    jct_set = [j[1] for j in S]
    time_set = [j[2] for j in S]

    for r in 1:length(S)
        time = time_set[r]
        for c in 1:length(Omega)
            train_id = Omega[c][2] #Find train ID for train
            departure_time = train_time_map[train_id] #Look up the departure time for that train
            
            #If a junction is in a path at a given time, change 0 to 1
            if jct_set[r] in path_set[c] 
                    #Currently, the junctions used by the trains are blocked for 3 minutes (departure time + 2 min)
                    if time >= departure_time && time <= departure_time + Dates.Minute(2)
                        init_m[r, c] = 1
                    end
            end
        end
    end
    
    #=count = 0
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

function mat_T(Omega::Vector{Vector})
    train_id = find_trains()[:,6]
    #initialize matrix
    init_m = zeros(Int, length(train_id), length(Omega))
    for i in 1:length(train_id)
        for j in 1:length(Omega)
            if train_id[i] == Omega[j][2]
                init_m[i,j] = 1
            end
        end
    end
    
    #=
    count = 0
    for value in Iterators.flatten(eachrow(init_m))  # Flatten the matrix row-wise
        print(value, " ")  # Print each number with a space
        count += 1
        if count % (33*23)== 0  # Insert a newline every 33 numbers
            println("")
            println("")
        end
    end
    =#

    return init_m
end

#Print function for all possible paths
function printpath(path::Vector{Int}) #Specifies the path has to be a vector of integers
    size = length(path)
    println("")
    for i in 1:size
        print(path[i], " ")
    end
    println
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

#Find all paths using BFS
function find_paths(g::Vector{Vector{Int}}, src::Vector{Int}, dst::Vector{Int}, v::Int) #v = number of vertices in g
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