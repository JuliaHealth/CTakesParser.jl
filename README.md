# CTakesParser.jl

Utilities to parse the output of cTAKES 4.0

### Installation 

Pkg.clone("https://github.com/bcbi/CTakesParser.jl.git")

### Example

The following example parses and returns a DataFrame using the the sample ctakes output file that is provided in the test directory.

```
file_in = PATH_TO_TESTS "/mts_sample_note_97_1152.txt.xmi"
ctakes_df = parse_output_v4(file_in)
```

The first 6 rows of the output DataFrame should look as follows:

```
julia> head(ctakes_df)
6×7 DataFrames.DataFrame
│ Row │ textsem             │ refsem        │ id   │ cui        │ negated │ preferred_text                │
├─────┼─────────────────────┼───────────────┼──────┼────────────┼─────────┼───────────────────────────────┤
│ 1   │ "MedicationMention" │ "UmlsConcept" │ 7425 │ "C0013227" │ false   │ "Pharmaceutical Preparations" │
│ 2   │ "MedicationMention" │ "UmlsConcept" │ 7445 │ "C0013227" │ false   │ "Pharmaceutical Preparations" │
│ 3   │ "MedicationMention" │ "UmlsConcept" │ 7435 │ "C0013227" │ false   │ "Pharmaceutical Preparations" │
│ 4   │ "MedicationMention" │ "UmlsConcept" │ 7554 │ "C0301532" │ false   │ "Multivitamin preparation"    │
│ 5   │ "MedicationMention" │ "UmlsConcept" │ 7544 │ "C0301532" │ false   │ "Multivitamin preparation"    │
│ 6   │ "MedicationMention" │ "UmlsConcept" │ 7564 │ "C0301532" │ false   │ "Multivitamin preparation"    │

│ Row │ scheme        │
├─────┼───────────────┤
│ 1   │ "SNOMEDCT_US" │
│ 2   │ "SNOMEDCT_US" │
│ 3   │ "SNOMEDCT_US" │
│ 4   │ "SNOMEDCT_US" │
│ 5   │ "SNOMEDCT_US" │
│ 6   │ "SNOMEDCT_US" │
```

### Note of running CTAKES

The sample file was obtained using:

    * CTakes 4.0
    * Clinical Pipeline
    * Command line interface

e.g.

`./bin/runClinicalPipeline.sh  -i /data/clinical_notes_input  --xmiOut /data/clinical_notes_output  --user $UMLS_USER  --pass $UMLS_PSSWD`
