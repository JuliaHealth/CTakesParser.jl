# CTakesParser.jl

| Travis CI | Coverage | License | 
|-----------|----------|---------|
|[![Build Status](https://travis-ci.org/bcbi/CTakesParser.jl.svg?branch=master)](https://travis-ci.org/bcbi/CTakesParser.jl)|[![codecov.io](http://codecov.io/github/bcbi/CTakesParser.jl/coverage.svg?branch=master)](http://codecov.io/githubbcbi/CTakesParser.jl?branch=master)|[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/bcbi/CTakesParser.jl/master/LICENSE.md)|

Julia utilities to parse the output of cTAKES 4.0

## Installation 

```
Pkg.clone("https://github.com/bcbi/CTakesParser.jl.git")
```

## Examples

### Parse all notes in a directory and save .csv output to disk

```
dir_in = "./notes_in/"
dir_out = "./notes_out/"

parse_output_dir(dir_in, dir_out)
```

### Parse individual file

The following example parses and returns a DataFrame using the the sample ctakes output file that is provided in the test directory.

```
file_in = PATH_TO_TESTS "/notes_in/mts_sample_note_97_1152.txt.xmi"
ctakes_df = parse_output_v4(file_in)
```

The first 6 rows of the output DataFrame should look as follows:

```
julia> head(ctakes_df)
6×7 DataFrames.DataFrame
│ Row │ textsem             │ refsem        │ id   │ cui        │ negated │
├─────┼─────────────────────┼───────────────┼──────┼────────────┼─────────┤
│ 1   │ "MedicationMention" │ "UmlsConcept" │ 7425 │ "C0013227" │ false   │
│ 2   │ "MedicationMention" │ "UmlsConcept" │ 7445 │ "C0013227" │ false   │
│ 3   │ "MedicationMention" │ "UmlsConcept" │ 7435 │ "C0013227" │ false   │
│ 4   │ "MedicationMention" │ "UmlsConcept" │ 7554 │ "C0301532" │ false   │
│ 5   │ "MedicationMention" │ "UmlsConcept" │ 7544 │ "C0301532" │ false   │
│ 6   │ "MedicationMention" │ "UmlsConcept" │ 7564 │ "C0301532" │ false   │

│ Row │ preferred_text                │ scheme        │
├─────┼───────────────────────────────┼───────────────┤
│ 1   │ "Pharmaceutical Preparations" │ "SNOMEDCT_US" │
│ 2   │ "Pharmaceutical Preparations" │ "SNOMEDCT_US" │
│ 3   │ "Pharmaceutical Preparations" │ "SNOMEDCT_US" │
│ 4   │ "Multivitamin preparation"    │ "SNOMEDCT_US" │
│ 5   │ "Multivitamin preparation"    │ "SNOMEDCT_US" │
│ 6   │ "Multivitamin preparation"    │ "SNOMEDCT_US" │
```

### Note on running CTAKES

The sample file was obtained using:

    * CTakes 4.0
    * Clinical Pipeline
    * Command line interface

e.g.

`./bin/runClinicalPipeline.sh  -i /data/clinical_notes_input  --xmiOut /data/clinical_notes_output  --user $UMLS_USER  --pass $UMLS_PSSWD`
