function addEdge(adj, u, v)
    push!(adj[u+1], v)  # Adjusting for 1-based indexing in Julia
end

function displayAdjList(adj)
    for (i, neighbors) in enumerate(adj)
        print("$i: ")
        println(join(neighbors, ", "))
    end
end

function main()
    V = 3
    adj = [Vector{Int}() for _ in 1:V]  # Initialize as a list of empty vectors

    # Add edges
    addEdge(adj, 1, 0)
    addEdge(adj, 1, 2)
    addEdge(adj, 2, 0)

    println("Adjacency List Representation:")
    displayAdjList(adj)
end

main()
