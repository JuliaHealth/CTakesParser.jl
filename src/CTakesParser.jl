module CTakesParser

using EzXML
using DataFrames
using CSV
using Missings

export parse_output_dir

import Base.get

function get(node::EzXML.Node, key::ANY, default::ANY)
    try
        getindex(node, key)
    catch
        default
    end
end

"""
    parse_output_dir(dir_in, dir_out)
Parse all notes in `dir_in` and save the .csv files corresponding to the
parsed dataframe into `dir_out`
Note that dir_in and dir_out are expected to end in \
"""
function parse_output_dir(dir_in, dir_out)

    if !isdir(dir_in)
        error("Input directory does not exist")
    end

    if !isdir(dir_out)
        mkpath(dir_out)
    end

    files = readdir(dir_in)

    info("--------------------------------------------------------")
    info("Parsing ", size(files), " files")
    info("--------------------------------------------------------")

    for f in files
        if !isfile(dir_in*f)
            warn(dir_in*f, "is not a file")
            continue
        end
        df = parse_output_v4(dir_in*f)
        filename = split(basename(f), ".")[1]
        file_out  = string(dir_out, filename, ".csv")
        CSV.write(file_out, df)
    end

end


"""
    parse_output_v4(file)

Parse the output of cTAKE v4.0.0 default clinical pipeline.
The output consists of a data-table with the following columns:
UMLS CONCEPT | SECTION | POSITION-BEGIN | POSITION-END | NEGATION
"""
function parse_output_v4(file_in)

    if !isfile(file_in)
        error("No input file: ", file_in)
    end

    xdoc = readxml(file_in)
    xroot = root(xdoc)

    results_df = DataFrame(textsem = Vector{String}(), refsem = Vector{String}(),
                           id = Vector{Int64}(), pos_start = Vector{Int64}(),
                           pos_end = Vector{Int64}(), cui=Vector{String}(),
                           negated = Vector{Bool}(), preferred_text=Vector{String}(),
                           scheme = Vector{String}(), tui = Vector{String}(),
                           score = Vector{Float64}(), confidence = Vector{Float64}(),
                           uncertainty = Vector{Int64}(), conditional = Vector{Bool}(),
                           generic = Vector{Bool}(), subject = Vector{String}())

    pos_df = DataFrame(pos_start = Vector{Int64}(), pos_end = Vector{Int64}(),
                       part_of_speech = Vector{String}(), text = Vector{String}())

    for (i,e) in enumerate(eachelement(xroot))

        if namespace(e) == "http:///org/apache/ctakes/typesystem/type/textsem.ecore"
            if haskey(e, "ontologyConceptArr")
                n = nodename(e)
                polarity = parse(get(e, "polarity", NaN))
                negated = !(polarity > 0)
                pos_start = parse(get(e, "begin", missing))
                pos_end = parse(get(e, "end", missing))

                confidence = parse(get(e, "confidence", missing))
                uncertainty = parse(get(e, "uncertainty", missing))
                conditional = parse(get(e, "conditional", missing))
                generic = parse(get(e, "generic", missing))
                subject = get(e, "subject", missing)

                oca = split(e["ontologyConceptArr"], " ")
                for c in oca
                    push!(results_df, [n, "NA", parse(c), pos_start, pos_end, "NA",
                                       negated, "NA", "NA", "NA", NaN, confidence,
                                       uncertainty, conditional, generic, subject ])
                end
            end
        end

        if namespace(e) == "http:///org/apache/ctakes/typesystem/type/refsem.ecore"
            n = nodename(e)
            scheme = get(e, "codingScheme", missing)
            cui = get(e, "cui", missing)
            text = get(e, "preferredText", missing)
            id = parse(get(e, "xmi:id", missing))
            tui = get(e, "tui", missing)
            score = parse(get(e, "score", missing))


            # results_df[results_df[:id].== id, [:refsem, :cui, :preferred_text, :scheme]] = []
            results_df[(results_df[:id].== id), :refsem] = n
            results_df[(results_df[:id].== id), :cui] = cui
            results_df[(results_df[:id].== id), :preferred_text] = text
            results_df[(results_df[:id].== id), :scheme] = scheme
            results_df[(results_df[:id].== id), :tui] = tui
            results_df[(results_df[:id].== id), :score] = score
        end

        if namespace(e) == "http:///org/apache/ctakes/typesystem/type/syntax.ecore"
           if nodename(e) == "ConllDependencyNode" && e["id"] != "0"
               postag = e["postag"]
               pos_start = parse(e["begin"])
               pos_end = parse(e["end"])
               text = e["form"]

               append!(pos_df, DataFrame(pos_start = pos_start, pos_end = pos_end,
                       part_of_speech = postag, text = text))

           end
        end
    end

    true_text = String[]

    for row in eachrow(results_df)
        pos_start = row[:pos_start]
        pos_end = row[:pos_end]

        text_array = String[]

        for row_ in eachrow(pos_df)
            if pos_start <= row_[:pos_start] < pos_end
                push!(text_array, row_[:text])
            end
        end
        push!(true_text, join(text_array, " "))
    end

    pos_df_subset = pos_df[:, [:part_of_speech, :pos_start]]
    final_df = join(results_df, pos_df_subset, on = [:pos_start], kind = :left)
    final_df[:true_text] = true_text
    final_df
end

end # module
