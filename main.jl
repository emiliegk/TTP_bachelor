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
include("visuals.jl")
using .visuals


function main()
    
    junct = 128
    to_kh = create_graph("to") #initialize direction of graph
    from_kh = create_graph("from")
    to_w = create_graph("to_w")
    from_w = create_graph("from_w")
    df = find_trains()
    #println(df)
    #println("")
    

    S = set_S(to_kh, from_kh, df)
    o = omega(to_kh, from_kh, to_w, from_w, junct, df)

    
    seen = []
   
    
   

    R = mat_R(S, o, df)
    T = mat_T(o, df)
    
    x = set_packing(T, R)
    id_op_path(T, x, o)


    #= 
    #Mock data (train ID, platform, start time in minutes, end time in minutes, color)
train_data = [
    (4302, 1, 0, 10, :blue),
    (4500, 2, 8, 18, :red),
    (4202, 2, 20, 30, :blue),
    (802, 2, 32, 38, :purple),
    (2404, 2, 40, 48, :green),
    (2302, 2, 42, 50, :orange),
    (2502, 2, 52, 60, :brown),
    (3501, 2, 54, 60, :pink),
    (2421, 3, 2, 12, :green),
    (319, 3, 14, 20, :red),
    (9623, 3, 26, 30, :purple),
    (1421, 3, 32, 36, :orange),
    (1020, 3, 38, 44, :blue),
    (1022, 3, 46, 50, :brown),
    (4521, 4, 10, 16, :red),
    (823, 4, 22, 28, :orange),
    (4325, 4, 48, 54, :green),
    (225, 4, 56, 60, :purple),
    (1019, 5, 0, 4, :green),
    (1406, 5, 24, 30, :blue),
    (1506, 5, 32, 38, :brown),
    (2306, 5, 40, 46, :orange),
    (2506, 5, 48, 54, :pink),
    (3429, 5, 56, 60, :blue),
    (6, 6, 16, 20, :red),
    (3427, 6, 28, 34, :purple),
    (21320, 6, 36, 42, :green),
    (1427, 6, 44, 50, :brown),
    (1030, 6, 52, 58, :orange),
    (9625, 7, 10, 14, :red),
    (21310, 7, 22, 26, :blue),
    (2327, 7, 30, 34, :green),
    (4329, 7, 40, 44, :purple),
    (3420, 8, 0, 4, :brown),
    (4308, 8, 6, 12, :orange),
    (1410, 8, 14, 20, :blue),
    (21327, 8, 22, 28, :red),
    (810, 8, 30, 36, :pink),
    (9312, 8, 38, 42, :green),
    (2510, 8, 48, 54, :brown),
    (2212, 8, 56, 60, :orange),
    (208, 8, 2, 8, :blue),
    (4410, 8, 10, 16, :red),
    (4508, 8, 20, 26, :purple),
    (2310, 8, 34, 40, :blue),
    (2431, 8, 42, 48, :green),
    (1038, 8, 50, 56, :brown),
    (2229, 8, 0, 6, :orange),
    (4529, 8, 6, 12, :pink),
    (2331, 8, 12, 18, :blue),
    (2531, 8, 46, 52, :red),
]

    create_swimlanes(train_data)
    =#

end

main()

