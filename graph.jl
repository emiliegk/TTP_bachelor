module Graph
export addEdge, create_graph, displayAdjList
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

function create_graph(dir::String)
    junct = 128 #Number of junctions
    if dir == "from"
        from_kh = [Vector{Int}() for _ in 1:junct]  # Initialize adjacancy array from Kh
        # Add edges 
        #from kh
        addEdge(from_kh, 1, 14)
        addEdge(from_kh, 2, 10)
        addEdge(from_kh, 3, 11)
        addEdge(from_kh, 4, 15)
        addEdge(from_kh, 5, 16)
        addEdge(from_kh, 6, 12)
        addEdge(from_kh, 7, 13)
        addEdge(from_kh, 8, 17)
        addEdge(from_kh, 10, 14)
        addEdge(from_kh, 11, 10)
        addEdge(from_kh, 11, 15)
        addEdge(from_kh, 12, 16)
        addEdge(from_kh, 13, 12)
        addEdge(from_kh, 13, 17)
        addEdge(from_kh, 14, 18)
        addEdge(from_kh, 15, 19)
        addEdge(from_kh, 16, 21)
        addEdge(from_kh, 17, 23)
        addEdge(from_kh, 18, 19)
        addEdge(from_kh, 18, 22)
        addEdge(from_kh, 19, 18)
        addEdge(from_kh, 19, 20)
        addEdge(from_kh, 20, 21)
        addEdge(from_kh, 20, 22)
        addEdge(from_kh, 21, 20)
        addEdge(from_kh, 21, 23)
        addEdge(from_kh, 22, 24)
        addEdge(from_kh, 23, 25)
        addEdge(from_kh, 24, 127)
        addEdge(from_kh, 25, 24)
        return from_kh,  1
    elseif dir == "to"
        to_kh = [Vector{Int}() for _ in 1:junct]  # Initialize adjacancy array from Nørreport
        #to kh
        addEdge(to_kh, 128, 25)
        addEdge(to_kh, 25, 23)
        addEdge(to_kh, 23, 21)
        addEdge(to_kh, 21, 16)
        addEdge(to_kh, 16, 5)
        addEdge(to_kh, 16, 12)
        addEdge(to_kh, 12, 6)
        addEdge(to_kh, 12, 13)
        addEdge(to_kh, 13, 7)
        addEdge(to_kh, 23, 17)
        addEdge(to_kh, 17, 8)
        addEdge(to_kh, 17, 13)
        addEdge(to_kh, 21, 20)
        addEdge(to_kh, 20, 19)
        addEdge(to_kh, 19, 15)
        addEdge(to_kh, 19, 18)
        addEdge(to_kh, 15, 4)
        addEdge(to_kh, 15, 11)
        addEdge(to_kh, 11, 3)
        addEdge(to_kh, 18, 14)
        addEdge(to_kh, 14, 10)
        addEdge(to_kh, 10, 2)
        addEdge(to_kh, 10, 11)
        addEdge(to_kh, 14, 1)
        return to_kh , 2
    else
        println("Error: Invalid direction.")
        println("Try either to or from")
        return nothing
    end
end

end