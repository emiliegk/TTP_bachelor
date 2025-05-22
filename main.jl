using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
using DataStructures
using XLSX
using Statistics
# using Gurobi

include("graph.jl") 
using .Graph
#=include("all_paths.jl")
using .All_paths=#
include("model_1and2.jl")
using .model_1and2
include("optimization.jl")
using .optimization

include("Plots.jl")
using .plot_m


function main()
    
    junct = 128
    to_kh = create_graph("to") #initialize direction of graph
    from_kh = create_graph("from")
    to_w = create_graph("to_w")
    from_w = create_graph("from_w")
    df = find_trains()
    
    
    
    #S = set_S(to_kh, from_kh, df)
    o = omega(to_kh, from_kh, to_w, from_w, junct, df)
    filtered_o = [inner_list for inner_list in o if length(inner_list[2]) != 0]
    path_lengths = length.([inner_list[2] for inner_list in filtered_o])
    println(length(o[2]))
    println("Avg: ", mean(path_lengths))
    println("median: ", median(path_lengths))
    println("std: ", std(path_lengths))
    println("min: ", minimum(path_lengths))
    println("macx: ", maximum(path_lengths))
    histogram_chart(path_lengths)

    #=
    R = mat_R(S, o, df)
    T = mat_T(o, df)
    
    x = set_packing(T, R, o)    
    opt = id_op_path(T, x, o)

    create_csv(df, opt)
=#
end

main()

