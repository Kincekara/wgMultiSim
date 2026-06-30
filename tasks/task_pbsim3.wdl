version 1.0

task pacbio_clr {
    input {
        String prefix
        File reference
        Int depth = 50
    }

    command <<<
        set -euo pipefail

        # generate reads
        pbsim \
        --strategy wgs \
        --method qshmm \
        --qshmm /usr/local/data/QSHMM-RSII.model \
        --depth ~{depth} \
        --pass-num 10 \
        --seed 42 \
        --length-min 10000 \
        --length-max 25000 \
        --length-mean 15000 \
        --prefix ~{prefix} \
        --genome ~{reference}

        # compress bams
        tar -cvf ~{prefix}.bams.tar.gz ~{prefix}_*.bam
    >>>

    output {
        String version = "3.5.0"
        File bams = "~{prefix}.bams.tar.gz"
    }

    runtime {
        docker: "quay.io/biocontainers/pbsim3:3.0.5--h9948957_2"
        memory: "16 GB"
        cpu: 8
        disks: "local-disk 100 SSD"
        preemptible: 0
    }


}