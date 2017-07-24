module CTakesParser


using LightXML

using EzXML
using DataFrames

file_in = "/Users/isa/dropbox_brown/bcbi/julia_packages/CTakesParser.jl/test/mts_sample_note_97_1152.txt.xmi"
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
                println([n, NA, parse(c), NA, negated, NA, NA])
                push!(results_df, [n, NA, parse(c), NA, negated, NA, NA])
            end
        end
    end

    if namespace(e) =="http:///org/apache/ctakes/typesystem/type/refsem.ecore" 
        n = name(e)
        scheme = e["codingScheme"]
        cui = e["cui"]
        text = e["preferredText"]
        id = parse(e["xmi:id"])

        # println(id, results_df[:id].== id)
        # results_df[results_df[:id].== id, [:refsem, :cui, :preferred_text, :scheme]] = []
        # println(results_df[(results_df[:id].== id), :refsem])
        results_df[(results_df[:id].== id), :refsem] = n
        results_df[(results_df[:id].== id), :cui] = cui
        results_df[(results_df[:id].== id), :preferred_text] = text
        results_df[(results_df[:id].== id), :scheme] = scheme

    end
end

# Find texts using XPath query.
for species_name in content.(find(primates, "//species/text()"))
    println("- ", species_name)
end

ces = content.(find(xroot, "refsem:UmlsConcept"))

for ce in ces

    this_id = attribute(ce, "'xmi:id'")
    push!(xmi_ids, this_id)
    push!(schemes, attribute(ce, "codingScheme"))
    push!(cuis, attribute(ce, "cui"))
    push!(preferred_text, attribute(ce, "preferredText"))

    
    push!(negated, contains(==, negated_ids, id)?true:false)

end


"""
    parse_output_v4(file)

Parse the output of cTAKE v4.0.0 default clinical pipeline.
The output consists of a data-table with the following columns:
UMLS CONCEPT | SECTION | POSITION-BEGIN | POSITION-END | NEGATION
"""
function parse_output_v4(file_in)
    
    file_in = "/Users/isa/dropbox_brown/bcbi/julia_packages/CTakesParser.jl/test/mts_sample_note_97_1152.txt.xmi"
    if !isfile(file_in)
        error("parse_output_v4: No input file")
    end

    schemes = Vector{String}()
    cuis = Vector{Int64}()
    negated_ids = Vector{Int64}()
    preferred_text = Vector{String}()
    negated = Vector{Bool}()

    xdoc = parse_file(file_in)
    xroot = root(xdoc)

    # # get a list of all child elemensts
    ces = collect(child_elements(xroot))


    # for (i,e) in enumerate(eachelement(xroot))
    #     println(content(e))

    #     if (i > 3)
    #         break
    #     end
    # end

    for concept in concept_list
        ces = get_elements_by_tagname(xroot, "textsem:$concept")

        for ce in ces

            polarity = attribute(ce, "polarity")
            if polarity == -1
                id = attribute(ce, "ontologyConceptArr")
                push!(negated_ids, id)
            end
        end
    end

    ces = get_elements_by_tagname(xroot, "refsem:UmlsConcept")

    for ce in ces

        this_id = attribute(ce, "'xmi:id'")
        push!(xmi_ids, this_id)
        push!(schemes, attribute(ce, "codingScheme"))
        push!(cuis, attribute(ce, "cui"))
        push!(preferred_text, attribute(ce, "preferredText"))

        
        push!(negated, contains(==, negated_ids, id)?true:false)
   
    end


end

end # module
