module CTakesParser


using EzXML
using DataFrames

export parse_output_v4

"""
    parse_output_v4(file)

Parse the output of cTAKE v4.0.0 default clinical pipeline.
The output consists of a data-table with the following columns:
UMLS CONCEPT | SECTION | POSITION-BEGIN | POSITION-END | NEGATION
"""
function parse_output_v4(file_in)
       
    if !isfile(file_in)
        error("parse_output_v4: No input file")
    end

    xdoc = readxml(file_in)
    xroot = root(xdoc)

    results_df = DataFrame(textsem = Vector{String}(), refsem = Vector{String}(), id = Vector{Int64}(), cui=Vector{String}(),
                        negated = Vector{Bool}(), preferred_text=Vector{String}(), scheme = Vector{String}())

    for (i,e) in enumerate(eachelement(xroot))
        
        if namespace(e) == "http:///org/apache/ctakes/typesystem/type/textsem.ecore"
            if haskey(e, "ontologyConceptArr")
            
                n = name(e)
                negated = !(parse(e["polarity"]) > 0)

                oca = split(e["ontologyConceptArr"], " ")
                for c in oca
                    push!(results_df, [n, "NA", parse(c), "NA", negated, "NA", "NA"])
                end
            end
        end

        if namespace(e) =="http:///org/apache/ctakes/typesystem/type/refsem.ecore" 
            n = name(e)
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
