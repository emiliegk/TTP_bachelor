using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
using DataStructures
using XLSX

include("graph.jl") 
using .Graph
include("all_paths.jl")
using .All_paths

function create_uses_junct(S, omega)
    n_junct = length(S)
    n_paths = length(omega)

    #initialize the matrix with zeros
    matrix = zeros(Int, n_junct, n_paths)
    for (col, path) in enumerate(omega)
        for junct in path
            matrix[junct, col] = 1
        end
    end
    #=
     # Print column headers (paths)
     print("Junction \\ Path | ")
     for col in 1:n_paths
         print("Path $col | ")
     end
     println()  
 
     # Print each row (junction) with its binary values
     for row in 1:n_junct
         print(lpad(S[row], 8), " | ")  # Print junction number (row label)
         for col in 1:n_paths
             print(lpad(matrix[row, col], 6), " | ")  # Print binary value
         end
         println()  
     end
     =#
    return matrix

end


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

    uses_junct = create_uses_junct(junct, all_p)

    omega(to_kn, srcs, dst, junct_kn)
   
end

main()

