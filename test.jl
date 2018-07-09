count = 0
for (i,e) in enumerate(eachelement(xroot))
   if namespace(e) == "http:///org/apache/ctakes/typesystem/type/syntax.ecore"
      if nodename(e) == "WordToken"
          postag = e["partOfSpeech"]
          pos_start = e["begin"]
          pos_end = e["end"]

          prinln(postag)
      end
   end
end


for (i,e) in enumerate(eachelement(xroot))

    if namespace(e) == "http:///org/apache/ctakes/typesystem/type/textsem.ecore"
        if haskey(e, "ontologyConceptArr")
            n = nodename(e)
            negated = !(parse(e["polarity"]) > 0)
            pos_start = parse(e["begin"])
            pos_end = parse(e["end"])
            println(e)
            oca = split(e["ontologyConceptArr"], " ")
            for c in oca
                println(c)
            end
        end
    end
end

for (i,e) in enumerate(eachelement(xroot))

    if namespace(e) == "http:///org/apache/ctakes/typesystem/type/refsem.ecore"
        n = nodename(e)

        id = parse(e["xmi:id"])
        println(e)
    end
end
