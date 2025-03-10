using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
#Pkg.add("XLSX")

using DataStructures
#Pkg.add("DataFrames")


module All_paths
using DataFrames
using XLSX
export printpath, not_visited, find_paths, find_trains, omega

#Finds trains to Nørreport
function find_trains()
    df = XLSX.readxlsx("Ophold_Kh.xlsx")
    sheet = df["Data"]
    data = sheet["B2:J"*string(size(sheet[:], 1))] 
    to_matrix = Matrix(data)  # Ensures row-wise structure

    #For now we are only interested in the trains going to Nørreport
    #This has to be changed later!!!!!
    
    #to_kn_trains = to_matrix[to_matrix[:, 8] .== "Nørreport", :]
    to_kn_trains = filter(x -> coalesce(x, "") == "Nørreport", to_matrix[:, 8])
    #println("The number of trains going from Kh to Kn is: ")
    #println(size(to_kn_trains,1))
    return to_kn_trains
end

#Function linking all possible paths 
function omega(graph::Vector{Int}, src::Vector{Int}, dst::Vector{Int}, v::Int)
    trains = find_trains()
    paths = find_paths(graph, src, dst, v)
    o = Vector{Vector}()
    for i in 1:length(trains)
        for j in 1:length(paths)
            push!(o, [paths[j],trains[i, 2]])

        end
    end
    println(o)
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
    path_ids = []
    for s in src #For every starting point (source)
        for d in dst #For every destination
            println("")
            print("Paths from platform $(s) to platform $(d): ")
        
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
                    push!(path_ids, path)
                    println("")
                    print("Path ", path_count, ": " )
                    printpath(path_ids[path_count])
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
            println("")
            print("----------------")
        end
    end
    println( "")
    return(path_ids)
end


end