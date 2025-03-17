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
    junct = 128
    from_kh = create_graph("to")

    df = find_trains()
    #println("Adjacency List Representation:")
    #displayAdjList(to_kn)
    #displayAdjList(from_kn)

    #Create starting point(s) and destination(s)
    
    dst = Int[]
    push!(dst, 127)

    #t_src = allocate_t_src(df)
    #Stores all paths as a vector of vectors
    #might not be the same omega as in the literature so be careful!!!!!!
    #all_p = find_paths(to_kn, t_src, dst, junct_kn) 

    #Creates vector with the junction numbers
    #=junct = Int[]
    for s in 1:junct_kn
        push!(junct, s)
    end=#

    S = set_S(from_kh, df)
    #o = omega(from_kh, t_src, dst, junct, df) figure out how omega can run so that we can 

    
   
end

main()

