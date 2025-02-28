using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
using DataStructures

function addEdge(adj, u, v) #Add edge from u to v
    push!(adj[u], v)  # Adjusting for 1-based indexing in Julia
end

function displayAdjList(adj)
    for (i, neighbors) in enumerate(adj)
        print("$i: ")
        println(join(neighbors, ", "))
        
    end
end

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
function find_paths(g::Vector{Vector{Int}}, src::Int, dst::Int, v::Int)
    #Create queue for path
    q = []

    #Path vector to store the current path
    path = Int[]
    push!(path, src)
    push!(q, copy(path))

    while !isempty(q)
        path = popfirst!(q)
        last = path[length(path)]

        #If last vertex is dst, print path
        if last == dst
            printpath(path)
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

function main()
    junct_kn = 128 #Number of junctions
    to_kn = [Vector{Int}() for _ in 1:junct_kn]  # Initialize adjacancy array to Nørreport
    from_kn = [Vector{Int}() for _ in 1:junct_kn]  # Initialize adjacancy array from Nørreport

    # Add edges 
    #to kn
    addEdge(to_kn, 1, 14)
    addEdge(to_kn, 2, 10)
    addEdge(to_kn, 3, 11)
    addEdge(to_kn, 4, 15)
    addEdge(to_kn, 5, 16)
    addEdge(to_kn, 6, 12)
    addEdge(to_kn, 7, 13)
    addEdge(to_kn, 8, 17)
    addEdge(to_kn, 10, 14)
    addEdge(to_kn, 11, 10)
    addEdge(to_kn, 11, 15)
    addEdge(to_kn, 12, 16)
    addEdge(to_kn, 13, 12)
    addEdge(to_kn, 13, 17)
    addEdge(to_kn, 14, 18)
    addEdge(to_kn, 15, 19)
    addEdge(to_kn, 16, 21)
    addEdge(to_kn, 17, 23)
    addEdge(to_kn, 18, 19)
    addEdge(to_kn, 18, 22)
    addEdge(to_kn, 19, 18)
    addEdge(to_kn, 19, 20)
    addEdge(to_kn, 20, 21)
    addEdge(to_kn, 20, 22)
    addEdge(to_kn, 21, 20)
    addEdge(to_kn, 21, 23)
    addEdge(to_kn, 22, 24)
    addEdge(to_kn, 23, 25)
    addEdge(to_kn, 24, 127)
    addEdge(to_kn, 25, 24)

    #from kn
    addEdge(from_kn, 128, 25)
    addEdge(from_kn, 25, 23)
    addEdge(from_kn, 23, 21)
    addEdge(from_kn, 21, 16)
    addEdge(from_kn, 16, 5)
    addEdge(from_kn, 16, 12)
    addEdge(from_kn, 12, 6)
    addEdge(from_kn, 12, 13)
    addEdge(from_kn, 13, 7)
    addEdge(from_kn, 23, 17)
    addEdge(from_kn, 17, 8)
    addEdge(from_kn, 17, 13)
    addEdge(from_kn, 21, 20)
    addEdge(from_kn, 20, 19)
    addEdge(from_kn, 19, 15)
    addEdge(from_kn, 19, 18)
    addEdge(from_kn, 15, 4)
    addEdge(from_kn, 15, 11)
    addEdge(from_kn, 11, 3)
    addEdge(from_kn, 18, 14)
    addEdge(from_kn, 14, 10)
    addEdge(from_kn, 10, 2)
    addEdge(from_kn, 10, 11)
    addEdge(from_kn, 14, 1)
    

    #println("Adjacency List Representation:")
    #displayAdjList(to_kn)
    #displayAdjList(from_kn)
    scrs = []
    for i in 1:8
        push!(scrs, i)
    end
    dst = 127

    

    for s in scrs
        println("")
        print("paths from platform $(s) to platform $(dst): ")
        find_paths(to_kn, s, dst, junct_kn)
        println( "")
    end
end

main()
