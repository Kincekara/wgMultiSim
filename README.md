# wgMultiSim

[![Dockstore](https://img.shields.io/badge/Dockstore-wgMultiSim-blue)](https://dockstore.org/workflows/github.com/Kincekara/wgMultiSim/wgMultiSim)
[![Terra.bio](https://img.shields.io/badge/Terra.bio-Platform-green)](https://terra.bio/)
[![Cromwell](https://img.shields.io/badge/Cromwell-Workflow%20Engine-blue)](https://cromwell.readthedocs.io/en/stable/)
[![MiniWDL](https://img.shields.io/badge/MiniWDL-Workflow%20Engine-yellow)](https://miniwdl.readthedocs.io/en/latest/)
[![CI](https://github.com/Kincekara/wgMultiSim/actions/workflows/check-wdl.yml/badge.svg)](https://github.com/Kincekara/wgMultiSim/actions/workflows/check-wdl.yml)

wgMultiSim is a WDL workflow for simulating bacterial whole genome sequencing data. It generates PacBio HiFi and/or Illumina paired-end short reads from a reference genome or an NCBI accession.

## Features

- Download a bacterial genome from NCBI using accession ID
- Simulate PacBio HiFi reads via PBSIM3 and CCS
- Simulate Illumina paired-end reads with ART

## Terra

- The pipeline is available as a [Dockstore workflow](https://dockstore.org/workflows/github.com/Kincekara/wgMultiSim/wgMultiSim) that can be imported directly into Terra for cloud execution.


### Inputs

| Input | Type | Description |
|---|---|---|
| `prefix` | String | Prefix for output file names |
| `reference` | File | reference genome. Required if `accession` is not provided |
| `accession` | String | NCBI accession. Required if `reference` is not provided |
| `hifi_depth` | Int | Sequencing Depth for PacBio HiFi simulation. ( default: 30X ) |
| `short_read_depth` | Int | Sequencing depth for Illumina short-read simulation. ( default: 50X ) |
| `short_reads` | Boolean | Enable Illumina read generation ( default: `true`) |
| `pacbio_hifi_reads` | Boolean | Enable PacBio HiFi simulation ( default: `true`) |

>[!NOTE]
> You should provide a complete reference genome in FASTA format or an NCBI accession. If both are provided, the reference genome will be used.

### Outputs

| Output | Description |
|---|---|
| `hifi_reads` | Merged HiFi BAM file (`*.merged.hifi.bam`) |
| `short_fq1` | Illumina paired-end read 1 (`*.fq.gz`) |
| `short_fq2` | Illumina paired-end read 2 (`*.fq.gz`) |
| `program_versions` | Runtime tool version strings |

## Local Execution

### Requirements

- [MiniWDL](https://miniwdl.readthedocs.io/en/latest/) or [Cromwell](https://cromwell.readthedocs.io/en/latest/) installed
- A container engine (Docker, Apptainer, etc.) installed and running locally for container execution
- 8+ CPU, 16+ GB RAM, and sufficient disk space

### Installation

```bash
git clone https://github.com/Kincekara/wgMultiSim.git
```

### Quick start

```bash
# Run the workflow with NCBI accession
miniwdl run /path/to/wf_wgmultisim.wdl prefix=sample_id accession=GCF_000005845.2
```
Alternatively,
```bash
# Run the workflow with a local reference genome
miniwdl run /path/to/wf_wgmultisim.wdl prefix=sample_id reference=/path/to/reference.fasta

# Run the workflow with accession & hifi only 
miniwdl run /path/to/wf_wgmultisim.wdl prefix=sample_id accession=GCF_000005845.2 short_reads=false

# Run the workflow with local reference & short reads only
miniwdl run /path/to/wf_wgmultisim.wdl prefix=sample_id reference=/path/to/reference.fasta hifi=false short_read_depth=30
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Support

For questions or issues, please open an issue on GitHub.