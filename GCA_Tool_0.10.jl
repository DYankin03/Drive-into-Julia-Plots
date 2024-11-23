using Plots
using CSV
using DataFrames
using ArgParse

function read_csv(file_path::String)
    # CSV reader function
    """
      read_csv(file_path::String)

      Read a CSV file and return a DataFrame.
    """
    
    # Read the CSV file, skipping the first two rows
    df = CSV.read(file_path, DataFrame, skipto=3)

    return df
end

function get_data(file_path::String)
    df = read_csv(file_path)

    title = df[!, "Strain:"][1]
    time = df[!, "Data"]
    OD = df[!, "OD"]
    println(title)
    println(time)
    println(OD)

    return time, OD, title
end

function display_data(x, y, title, save_path::String)
    # Get the maximum and minimum time values
    max_time = maximum(x)
    min_time = minimum(x)
    
    max_OD = maximum(y)
    min_OD = minimum(y)

    # Plot the data
    if occursin("3154", title)
        p = plot(x, y, seriestype = :line,
            title = "Growth Curve",
            xlabel = "Time (h)",
            ylabel = "OD₇₃₀ (nm)",
            label = title,
            linewidth = 5,          # Line thickness
            linecolor = :green,      # Line color

            marker = :circle,       # Marker type
            markersize = 5,         # Marker size
            markercolor = :yellow,     # Marker color
            markerstrokewidth = 1,  # Marker Border width

            linestyle = :solid,      # Line style, solid, dash, dot
            grid = true,          # Add grid          # Add box
    
            xlims = (0, max_time + 10),   # Set x-axis limits
            ylims = (0, max_OD)) # Set y-axis limits

    elseif occursin("2973", title)
       p = plot(x, y, seriestype = :line,
          title = "Growth Curve",
          xlabel = "Time (h)",
          ylabel = "OD₇₃₀ (nm)",
          label = title,
          linewidth = 5,          # Line thickness
          linecolor = :lightgreen,      # Line color
    
          marker = :circle,       # Marker type
          markersize = 5,         # Marker size
          markercolor = :yellow,     # Marker color
          markerstrokewidth = 1,  # Marker Border width
    
          linestyle = :solid,      # Line style, solid, dash, dot
          grid = true,          # Add grid          # Add box
    
          xlims = (min_time, max_time),   # Set x-axis limits
          ylims = (0, maximum(y))) # Set y-axis limits

    else
        p = plot(x, y, seriestype = :line,
            title = "Growth Curve",
            xlabel = "Time (h)",
            ylabel = "OD",
            label = title,
            linewidth = 5,          # Line thickness
            linecolor = "#da86a5",      # Line color
            marker = :circle,       # Marker type
            markersize = 5,         # Marker size
            markercolor = :lightblue,     # Marker color
            linestyle = :solid,      # Line style, solid, dash, dot
            grid = false,            # Add grid

            xlims = (0, max_time + 10),   # Set x-axis limits
            ylims = (0, max_OD + 0.1)) # Set y-axis limits
    end
    
    # Set X-axis tick marks to every 24 hours
    xticks = 0:24:max_time
    xticks!(p, xticks)

    # Add dashed vertical lines every 24 hours
    for t in 0:24:max_time
      vline!(p, [t], 
            linestyle = :dash, 
            linecolor = :grey, 
            linewidth = 1, 
            alpha = 0.5,
            label = false)
  end

    display(p)
    
    # Save the plot to the specified location
    savefig(p, save_path)
end

function process_files(input::String, output::String)
    input_folder = expanduser(input)
    output_folder = expanduser(output)
    for file in readdir(input_folder)
        try
            # Construct the full file path
            file_path = joinpath(input_folder, file)
            
            # Process the file
            x, y, title = get_data(file_path)
            
            # Construct the save path
            save_path = joinpath(output_folder, "$(title)_growth_curve.png")
            
            # Display and save the plot
            display_data(x, y, title, save_path)
        catch e
            println("Error processing file $file: $e")
        end
    end
end

function main(input::String, output::String)
    process_files(input, output)
end

function parse_command_line_args()
  s = ArgParseSettings()
  @add_arg_table! s begin
      "-i", "--input"
      help = "Path to the input folder"
      
      "-o", "--output"
      help = "Path to the output folder"
  end
  return parse_args(s)
end

args = parse_command_line_args()
main(get(args, "input", ""), get(args, "output", ""))