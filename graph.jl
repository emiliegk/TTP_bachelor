function addEdge(adj, u, v) #Add edge from u to v
    push!(adj[u], v)  # Adjusting for 1-based indexing in Julia
end

function displayAdjList(adj)
    for (i, neighbors) in enumerate(adj)
        print("$i: ")
        println(join(neighbors, ", "))
        
    end
end

function main()
    junct_kn = 128 #Number of junctions
    to_kn = [Vector{Int}() for _ in 1:junct_kn]  # Initialize adjacancy array to Nørreport
    from_kn = [Vector{Int}() for _ in 1:junct_kn]  # Initialize adjacancy array from Nørreport

    # Add edges
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

    println("Adjacency List Representation:")
    displayAdjList(to_kn)
    #displayAdjList(from_kn)
end

main()
