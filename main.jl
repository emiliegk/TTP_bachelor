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
    to_kh = create_graph("to") #initialize direction of graph
    from_kh = create_graph("from")
    df = find_trains()



    #S = set_S(to_kh, from_kh, df)
    #o = omega(to_kh, from_kh, junct, df)
    
   
    #R = mat_R(S, o, df, dir)
    #T = mat_T(dir, o, df)
    
    #x = set_packing(T, R)
    #id_op_path(T, x, o)
    

end

main()

