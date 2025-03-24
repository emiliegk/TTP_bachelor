using Pkg
using DataStructures


module visuals
using DataFrames
using XLSX
using Dates
using Plots
export  create_swimlanes




function create_swimlanes(train_data)

    platforms = 1:8
    time_range = 0:180 # 6:00 AM to 9:00 AM in minutes

    plot() # Initialize an empty plot

    for (train_id, platform, start_time, end_time, color) in train_data
        # Calculate the width and position of the bar
        bar_width = end_time - start_time
        bar_position = start_time

        # Use bar! with orientation=:h for horizontal bars
        bar!([platform], [bar_width], bar_position, color=color, orientation=:h, legend=false)
        
        # Add the train ID to the middle of the bar
        annotate!(start_time + bar_width / 2, platform, text(train_id, 8, :black, :center))
    end

    # Customize the y-axis (platforms)
    yaxis!(platforms, "Platform")

    # Customize the x-axis (time labels)
    tick_positions = 0:30:180  # Positions for ticks (every 30 minutes)
    tick_labels = [string(6 + i * 0.5, ":00") for i in 0:6]  # Labels for ticks
    xaxis!(tick_positions, tick_labels, "Time (HH:MM)")

    # Set axis limits
    xlims!(0, 180)
    ylims!(0.5, 8.5)

    # Save the plot to a file
    savefig("swimlanes.png")
    
end





end