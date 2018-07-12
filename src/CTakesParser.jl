module CTakesParser

using EzXML
using DataFrames
using CSV

export parse_output_dir


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
                       part_of_speech = Vector{String}(), true_text = Vector{String}())

    for (i,e) in enumerate(eachelement(xroot))

        if namespace(e) == "http:///org/apache/ctakes/typesystem/type/textsem.ecore"
            if haskey(e, "ontologyConceptArr")
                n = nodename(e)
                negated = !(parse(e["polarity"]) > 0)
                pos_start = parse(e["begin"])
                pos_end = parse(e["end"])

                confidence = parse(e["confidence"])
                uncertainty = parse(e["uncertainty"])
                conditional = parse(e["conditional"])
                generic = parse(e["generic"])
                subject = e["subject"]

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
            scheme = e["codingScheme"]
            cui = e["cui"]
            text = e["preferredText"]
            id = parse(e["xmi:id"])
            tui = e["tui"]
            score = parse(e["score"])


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
                       part_of_speech = postag, true_text = text))

           end
        end
    end
    out_df = join(results_df, pos_df, on = [:pos_start, :pos_end], kind = :left)
    out_df
end

end # module
