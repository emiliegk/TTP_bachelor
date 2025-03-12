using Pkg
# Add if you don't have the package: Pkg.add("DataStructures") 
#Pkg.add("XLSX")
#Pkg.add("Dates")
using DataStructures
#Pkg.add("DataFrames")


module optimization
using DataFrames
using XLSX
using Dates
using JuMP
using GLPK

#=include("all_paths.jl")
using .All_paths=#

export set_packing

function set_packing(T, R)
    return 1
    
end

end


