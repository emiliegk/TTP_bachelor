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
    dir = create_graph("to") #initialize direction of graph

    df = find_trains(dir)
    println(df)
    println("")
    #=
    #println("Adjacency List Representation:")
    #displayAdjList(to_kn)
    #displayAdjList(from_kn)

    #Create starting point(s) and destination(s)
    
    
    
    
   

    t_src = allocate_t_src(dir, df)
    t_dst = allocate_t_dst(dir, df)


    S = set_S(dir, df)
    o = omega(dir, t_src, t_dst, junct, df)
  
    R = mat_R(S, o, df, dir)
    T = mat_T(dir, o, df)
    x = (set_packing(T, R))
    id_op_path(T, x, o)
    =#
    
   
end

main()

