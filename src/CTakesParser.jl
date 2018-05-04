module CTakesParser

using EzXML
using DataFrames
using CSV

export parse_output_dir


"""
    parse_output_dir(dir_in, dir_out)
Parse all notes in `dir_in` and save the .csv files corresponding to the
parsed dataframe into `dir_out`
"""
function parse_output_dir(dir_in, dir_out)
    
    if !isdir(dir_in)
        error("Input directory does not exist")
    end

    if !isdir(dir_out)
        mkpath(dir_out)
    end

    files = readdir(dir_in)

    for f in files
        if !isfile(f)
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

    results_df = DataFrame(textsem = Vector{String}(), refsem = Vector{String}(), id = Vector{Int64}(), cui=Vector{String}(),
                        negated = Vector{Bool}(), preferred_text=Vector{String}(), scheme = Vector{String}())

    for (i,e) in enumerate(eachelement(xroot))
        
        if namespace(e) == "http:///org/apache/ctakes/typesystem/type/textsem.ecore"
            if haskey(e, "ontologyConceptArr")      
                n = nodename(e)
                negated = !(parse(e["polarity"]) > 0)

                oca = split(e["ontologyConceptArr"], " ")
                for c in oca
                    push!(results_df, [n, "NA", parse(c), "NA", negated, "NA", "NA"])
                end
            end
        end

        if namespace(e) =="http:///org/apache/ctakes/typesystem/type/refsem.ecore" 
            n = nodename(e)
            scheme = e["codingScheme"]
            cui = e["cui"]
            text = e["preferredText"]
            id = parse(e["xmi:id"])

            # results_df[results_df[:id].== id, [:refsem, :cui, :preferred_text, :scheme]] = []
            results_df[(results_df[:id].== id), :refsem] = n
            results_df[(results_df[:id].== id), :cui] = cui
            results_df[(results_df[:id].== id), :preferred_text] = text
            results_df[(results_df[:id].== id), :scheme] = scheme

        end
    end

    results_df
end

end # module
