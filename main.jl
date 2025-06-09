using Pkg
using DataStructures
using XLSX
using Statistics
using Gurobi

include("graph.jl") 
using .Graph

#=include("model_3.jl")
using .model_3=#
#If you want to use model_3.jl, uncomment the lines above and comment the lines below
include("model_1and2.jl")
using .model_1and2 

include("optimization.jl")
using .optimization

include("path_lengths_histogram.jl")
using .plot_histogram


function main()
    
    #Initialization of graph network (railway network):
    junct = 128
    to_kh = create_graph("to") 
    from_kh = create_graph("from")
    to_w = create_graph("to_w")
    from_w = create_graph("from_w")

    #Define which train schedule to use:
    df = find_trains("A.1.i_2022_Train_Schedule.xlsx") #Make sure the file is in the same directory as this script
    
    #Create R and T matrices:
    S = set_S(to_kh, from_kh, df)
    o = omega(to_kh, from_kh, to_w, from_w, junct, df)
    R = mat_R(S, o, df)
    T = mat_T(o, df)
    
    #Run optimization:
    x = set_packing(T, R, o)    
    opt = id_op_path(T, x, o)

    #Print the results in csv to create input file for swimlane_generator.py
    create_csv(df, opt)

    #If path lengths histogram is needed, uncomment the line below
    #=
    all_lengths = length.([inner_list[2] for inner_list in o])
    # Filter out the zero-length paths
    non_zero_lengths = filter(x -> x != 0, all_lengths)
    histogram_chart(non_zero_lengths)=#
end

main()

