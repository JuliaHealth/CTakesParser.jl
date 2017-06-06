module CTakesParser


using LightXML

"""
    parse_output_v4(file)

Parse the output of cTAKE v4.0.0 default clinical pipeline.
The output consists of a data-table with the following columns:
UMLS CONCEPT | SECTION | POSITION-BEGIN | POSITION-END | NEGATION
"""
function parse_output_v4(in_file, out_file, concept_list)

    if !isfile(in_file)
        error("parse_output_v4: No input file")
    end

    snomeds = Vector{Int64}()
    rxnorms = Vector{Int64}()
    cuis = Vector{Int64}()
    negated_ids = Vector{Int64}()

    xdoc = parse_file(in_file)
    xroot = root(xdoc)

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

        scheme = attribute(ce, "codingScheme")

        if scheme == "RXNORM"
        end

        if scheme == "SNOMEDCT_US"

    end


end

end # module
