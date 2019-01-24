using CTakesParser
using Test
using DataFrames
using CSV

function test_output_df(df)
    @test nrow(df) == 157
    # @test sum(completecases(df)) == 134
    @test sum(df[:scheme] .== "SNOMEDCT_US") == 149
    @test sum(df[:scheme] .== "RXNORM") == 8
    @test sum(df[:refsem] .== "UmlsConcept") == 157
end

function runtests()
    #test parsing individual file
    @testset "Parse file" begin
        println("-----------------------------------------")
        file_in = dirname(@__FILE__) * "/notes_in/mts_sample_note_97_1152.txt.xmi"
        ctakes_df = CTakesParser.parse_output_v4(file_in)
        test_output_df(ctakes_df)
    end

    #test parsing full directory
    @testset "Parse directory" begin
        println("-----------------------------------------")
        dir_in = dirname(@__FILE__) * "/notes_in/"
        dir_out = dirname(@__FILE__) * "/notes_out/"

        parse_output_dir(dir_in, dir_out)

        #read output files and test
        for f in [x for x in readdir(dir_out) if !endswith(x, ".log")]
            println("File: ", f)
            df =  CSV.read(dir_out*f)
            test_output_df(df)
        end
    end
end

runtests()
