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
        CSV.write(file_out, df, missingstring="NULL")
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

    results_df = DataFrame(textsem = Vector{Union{String,Missing}}(), refsem = Vector{Union{String,Missing}}(),
                           id = Vector{Union{Int64,Missing}}(), pos_start = Vector{Union{Int64,Missing}}(),
                           pos_end = Vector{Union{Int64,Missing}}(), cui=Vector{Union{String,Missing}}(),
                           negated = Vector{Union{Bool,Missing}}(), preferred_text=Vector{Union{String,Missing}}(),
                           scheme = Vector{Union{String,Missing}}(), tui = Vector{Union{String,Missing}}(),
                           score = Vector{Union{Float64,Missing}}(), confidence = Vector{Union{Float64,Missing}}(),
                           uncertainty = Vector{Union{Int64,Missing}}(), conditional = Vector{Union{Bool,Missing}}(),
                           generic = Vector{Union{Bool,Missing}}(), subject = Vector{Union{String,Missing}}())

    pos_df = DataFrame(pos_start = Vector{Union{Int64,Missing}}(), pos_end = Vector{Union{Int64,Missing}}(),
                       part_of_speech = Vector{Union{String,Missing}}(), text = Vector{Union{String,Missing}}())

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
                    push!(results_df, [n, missing, parse(c), pos_start, pos_end, missing,
                                       negated, missing, missing, missing, missing, confidence,
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
               postag = get(e, "postag", missing)
               pos_start = parse(get(e, "begin", missing))
               pos_end = parse(get(e, "end", missing))
               text = get(e, "form", missing)

               push!(pos_df, [pos_start, pos_end, postag, text])

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
