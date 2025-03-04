using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
using DataStructures
module All_paths
export printpath, not_visited, find_paths


function printpath(path::Vector{Int}) #Specifies the path has to be a vector of integers
    size = length(path)
    println("")
    for i in 1:size
        print(path[i], " ")
    end
    println
end

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