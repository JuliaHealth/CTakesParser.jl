# CTakesParser.jl

| Travis CI | Coverage | License |
|-----------|----------|---------|
|[![Build Status](https://travis-ci.org/bcbi/CTakesParser.jl.svg?branch=master)](https://travis-ci.org/bcbi/CTakesParser.jl)|[![codecov.io](http://codecov.io/github/bcbi/CTakesParser.jl/coverage.svg?branch=master)](http://codecov.io/githubbcbi/CTakesParser.jl?branch=master)|[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/bcbi/CTakesParser.jl/master/LICENSE.md)|

Julia utilities to parse the output of cTAKES 4.0

## Installation

```
using Pkg
Pkg.add("https://github.com/bcbi/CTakesParser.jl.git")
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

The first 8 rows of the output DataFrame should look as follows:

```
julia> head(ctakes_df)
8×17 DataFrames.DataFrame
│ Row │ textsem               │ refsem      │ id    │ pos_start │ pos_end │ cui      │ negated │ preferred_text              │ scheme      │ tui  │ score │ confidence │ uncertainty │ conditional │ generic │ subject │ part_of_speech │
├─────┼───────────────────────┼─────────────┼───────┼───────────┼─────────┼──────────┼─────────┼─────────────────────────────┼─────────────┼──────┼───────┼────────────┼─────────────┼─────────────┼─────────┼─────────┼────────────────┤
│ 1   │ MedicationMention     │ UmlsConcept │ 7425  │ 761       │ 772     │ C0013227 │ false   │ Pharmaceutical Preparations │ SNOMEDCT_US │ T121 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NNS            │
│ 2   │ MedicationMention     │ UmlsConcept │ 7445  │ 761       │ 772     │ C0013227 │ false   │ Pharmaceutical Preparations │ SNOMEDCT_US │ T121 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NNS            │
│ 3   │ MedicationMention     │ UmlsConcept │ 7435  │ 761       │ 772     │ C0013227 │ false   │ Pharmaceutical Preparations │ SNOMEDCT_US │ T121 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NNS            │
│ 4   │ MedicationMention     │ UmlsConcept │ 7554  │ 774       │ 787     │ C0301532 │ false   │ Multivitamin preparation    │ SNOMEDCT_US │ T127 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NNS            │
│ 5   │ MedicationMention     │ UmlsConcept │ 7544  │ 774       │ 787     │ C0301532 │ false   │ Multivitamin preparation    │ SNOMEDCT_US │ T109 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NNS            │
│ 6   │ MedicationMention     │ UmlsConcept │ 7564  │ 774       │ 787     │ C0301532 │ false   │ Multivitamin preparation    │ SNOMEDCT_US │ T121 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NNS            │
│ 7   │ MedicationMention     │ UmlsConcept │ 7921  │ 792       │ 799     │ C0006675 │ false   │ Calcium                     │ SNOMEDCT_US │ T121 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NN             │
│ 8   │ MedicationMention     │ UmlsConcept │ 7891  │ 792       │ 799     │ C0006675 │ false   │ Calcium                     │ RXNORM      │ T123 │ 0.0   │ 0.0        │ 0           │ false       │ false   │ patient │ NN             │
```

### Note on running CTAKES

The sample file was obtained using:

    * CTakes 4.0
    * Clinical Pipeline
    * Command line interface

e.g.

`./bin/runClinicalPipeline.sh  -i /data/clinical_notes_input  --xmiOut /data/clinical_notes_output  --user $UMLS_USER  --pass $UMLS_PSSWD`
