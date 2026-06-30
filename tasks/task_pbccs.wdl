version 1.0

task ccs {
    input {
        String prefix
        File subreads
    }

    command <<<
        set -euo pipefail

        # version
        ccs --version | head -n1 | cut -d " " -f2 > VERSION

        # extract subreads
        tar -xvf ~{subreads}

        # generate hifi reads for each subread
        for i in *.bam; do
            name="${i%.bam}"
            ccs "$i" "${name}.hifi.bam"
        done  

        tar -cvf ~{prefix}.hifi.bams.tar.gz ./*.hifi.bam
    >>>       

    output {
        String version = read_string("VERSION")
        File hifi_reads = "~{prefix}.hifi.bams.tar.gz"
    }

    runtime {
        docker: "quay.io/biocontainers/pbccs:6.4.0--h9ee0642_0"
        cpu: 8
        memory: "16 GB"
        preemptible: 0
    }
}