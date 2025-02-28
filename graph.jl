function addEdge(adj, u, v) #Add edge from u to v
    push!(adj[u+1], v)  # Adjusting for 1-based indexing in Julia
end

function displayAdjList(adj)
    for (i, neighbors) in enumerate(adj)
        print("$i: ")
        println(join(neighbors, ", "))
    end
end

function main()
    junct_kn = 26 #Number of junctions
    to_kn = [Vector{Int}() for _ in 1:junct_kn]  # Initialize adjacancy array to Nørreport
    from_kn = [Vector{Int}() for _ in 1:junct_kn]  # Initialize adjacancy array from Nørreport

    # Add edges
    addEdge(to_kn, 1, 14)

    println("Adjacency List Representation:")
    displayAdjList(to_kn)
    displayAdjList(from_kn)
end

main()
