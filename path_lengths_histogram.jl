
module plot_histogram
export histogram_chart
using Plots
using Statistics
using StatsBase

function histogram_chart(paths::Vector{Int64})
    path_lengths = paths
    println("Statistical Summary:")
    println("- Average length: ", round(mean(path_lengths); digits=2))
    println("- Total paths: ", length(path_lengths))
    println("- Minimum length: ", minimum(path_lengths))
    println("- Maximum length: ", maximum(path_lengths))
    println("- Median length: ", median(path_lengths))
    
    hist_data = fit(Histogram, path_lengths, 
                   nbins=clamp(ceil(Int, sqrt(length(path_lengths))), 10, 200))
    
    # Create the histogram plot 
    p = histogram(path_lengths,
            bins=hist_data.edges[1],
            title="Histogram of Path Lengths 2022",
            xlabel="Path Length",
            ylabel="Frequency (count)",
            legend=true,  
            legendfontsize=18,
            label="Paths",
            color=:viridis,
            size=(1600, 900),
            dpi=300,
            xguidefontsize=18,      
            yguidefontsize=18,      
            xtickfontsize=18, 
            ytickfontsize=18,
            titlefontsize=20,
            fillalpha=0.7,
            linecolor=:black,
            margin=10Plots.mm, 
            yformatter=y -> string(round(Int, y)) * " ")
    
    # Add reference lines with explicit labels
    vline!([mean(path_lengths)], 
           line=(:dash, 2, :red), 
           label="Mean ($(round(mean(path_lengths); digits=1)))")  
    
    vline!([median(path_lengths)], 
           line=(:dash, 2, :blue), 
           label="Median ($(round(median(path_lengths); digits=1)))")  
    
    max_freq = maximum(hist_data.weights)
    annotate!(maximum(path_lengths)*0.7, max_freq*0.9, 
             text("number of paths = $(length(path_lengths))", 14))
    Plots.display(p)

    # Save the plot as a PNG file
    savefig(p, "path_lengths_2022.png") 
    println("Plot saved as 'path_lengths_2022.png'") #Make sure the name matches the file you save
    return p
end

end