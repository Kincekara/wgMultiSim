version 1.0

task dl_genome {
    input {
        String accession
    }
    command <<<
        set -euo pipefail

        # version
        datasets --version | cut -d " " -f 3 > VERSION

        # download accession 
        datasets download genome accession ~{accession}
        unzip -j -p ncbi_dataset.zip "*.fna" > ~{accession}.fasta
        rm ncbi_dataset.zip
    >>>

    output {
        String version = read_string("VERSION")
        File fasta = "~{accession}.fasta"
    }

    runtime {
        docker: "staphb/ncbi-datasets:18.31.0"
        memory: "1 GB"
        cpu: 1
        preemptible: 0
    }
}