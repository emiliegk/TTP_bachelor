using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
using DataStructures
using XLSX
using Gurobi

include("graph.jl") 
using .Graph
include("all_paths.jl")
using .All_paths
include("optimization.jl")
using .optimization



function main()
    
    junct = 128
    to_kh = create_graph("to") #initialize direction of graph
    from_kh = create_graph("from")
    to_w = create_graph("to_w")
    from_w = create_graph("from_w")
    df = find_trains()
    
    
    
    S = set_S(to_kh, from_kh, df)
    o = omega(to_kh, from_kh, to_w, from_w, junct, df) 

    
    R = mat_R(S, o, df)
    T = mat_T(o, df)
    
    x = set_packing(T, R, o)    
    opt = id_op_path(T, x, o)

    create_csv(df, opt)

end

main()

