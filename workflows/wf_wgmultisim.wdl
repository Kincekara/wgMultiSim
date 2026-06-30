version 1.0

import "../tasks/task_pbsim3.wdl" as pbsim
import "../tasks/task_pbtk.wdl" as pbtk
import "../tasks/task_pbccs.wdl" as pbccs
import "../tasks/task_datasets.wdl" as datasets
import "../tasks/task_pad.wdl" as pad
import "../tasks/task_art.wdl" as art


workflow wgmultisim {
    meta {
        author: "Kutluhan Incekara"
        email: "kutluhan.incekara@ct.gov"
        description: "Simulate PacBio HiFi and Illumina short reads for bacterial genomes."
    }

    parameter_meta {
        prefix: {
            description: "Prefix for output files"
        }
        reference: {
            description: "Reference genome in fasta format. If not provided, accession must be provided.",
            patterns: ["*.fasta", "*.fna", "*.fa"]
        }
        accession: {
            description: "NCBI accession number of the reference genome. If not provided, reference must be provided.",
            patterns: ["^GC[A|F]_[0-9]{9}\.[0-9]+"]
        }
        pacbio_hifi_reads: {
            description: "Whether to generate PacBio HiFi reads",
            patterns: ["true", "false"],
            default: "true"
        }
        hifi_depth: {
            description: "Depth of coverage for PacBio HiFi reads."
        }
        short_reads: {
            description: "Whether to generate Illumina short reads"
            patterns: ["true", "false"],
            default: "true"
        }
        short_read_depth: {
            description: "Depth of coverage for Illumina short reads."
        }
    }

    input {
        String prefix
        File? reference
        String accession = ""
        Int? hifi_depth
        Int? short_read_depth
        Boolean short_reads = true
        Boolean pacbio_hifi_reads = true
    }

    if (!defined(reference)) {
        call datasets.dl_genome {
            input:
                accession = accession
        }
    }

    if (short_reads) {
        call art.illumina_pe {
            input:
                prefix = prefix,
                genome = select_first([dl_genome.fasta, reference]),
                depth = short_read_depth
        }
    }

    if (pacbio_hifi_reads) {
        call pad.pad_genome {
            input:
                genome = select_first([dl_genome.fasta, reference])
        }

        call pbsim.pacbio_clr {
            input:
                prefix = prefix,
                reference = pad_genome.padded_genome,
                depth = hifi_depth
        }

        call pbccs.ccs {
            input:
                prefix = prefix,
                subreads = pacbio_clr.bams
        }

        call pbtk.pbmerge {
            input:
                prefix = prefix,
                bams = ccs.hifi_reads
        }
    }

    output {
        String version = "wgMultiSim v0.1.0"
        File? hifi_reads = pbmerge.merged_hifi_reads
        File? short_fq1 = illumina_pe.short_fq1
        File? short_fq2 = illumina_pe.short_fq2
        Array[String] program_versions = [ "art: " + select_first([illumina_pe.version, "NA"]),
                                        "datasets: " + select_first([dl_genome.version, "NA"]),
                                        "pbsim3: " + select_first([pacbio_clr.version, "NA"]),
                                        "pbccs: " + select_first([ccs.version, "NA"]),
                                        "pbtk: " + select_first([pbmerge.version, "NA"])
                                        ]

    }
}