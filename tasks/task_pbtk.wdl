version 1.0

task pbmerge {
    input {
        String prefix
        File bams
        Int cpu = 4
    }

    command <<<
        set -euo pipefail

        # version
        pbmerge --version | head -n1 | cut -d " " -f2 > VERSION

        # extract bams
        tar -xvf ~{bams}

        # merge bams
        pbmerge -j ~{cpu} -o ~{prefix}.merged.hifi.bam ./*.hifi.bam
    >>>

    output {
        String version = read_string("VERSION")
        File merged_hifi_reads = "~{prefix}.merged.hifi.bam"
    }

    runtime {
        docker: "staphb/pbtk:3.5.0"
        cpu: cpu
        memory: "8 GB"
        preemptible: 0
    }

}