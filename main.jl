using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
using DataStructures
using XLSX

include("graph.jl") 
using .Graph
include("all_paths.jl")
using .All_paths
include("optimization.jl")
using .optimization


function main()
    junct_kn = 128

    to_kn = create_graph("to")

    #println("Adjacency List Representation:")
    #displayAdjList(to_kn)
    #displayAdjList(from_kn)

    #Create starting point(s) and destination(s)
    srcs = Int[]
    for i in 1:8
        push!(srcs, i)
    end
    dst = Int[]
    push!(dst, 127)

    #Stores all paths as a vector of vectors
    #might not be the same omega as in the literature so be careful!!!!!!
    all_p = find_paths(to_kn, srcs, dst, junct_kn) 

    #Creates vector with the junction numbers
    junct = Int[]
    for s in 1:junct_kn
        push!(junct, s)
    end

    S = set_S(to_kn)
    o = omega(to_kn, srcs, dst, junct_kn)

    set_packing(mat_T(o),mat_R(S,o))

   
end

main()

