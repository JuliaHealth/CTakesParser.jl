using CTakesParser
using Base.Test
using DataFrames

file_in = filename = dirname(@__FILE__) * "/mts_sample_note_97_1152.txt.xmi"

ctakes_df = parse_output_v4(file_in)

@test nrow(ctakes_df) == 157
@test sum(completecases(ctakes_df)) == 157
@test sum(ctakes_df[:scheme] .== "SNOMEDCT_US") == 149
@test sum(ctakes_df[:scheme] .== "RXNORM") == 8
@test sum(ctakes_df[:refsem] .== "UmlsConcept") == 157