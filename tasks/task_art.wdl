version 1.0

task illumina_pe {
    input {
        String prefix
        File genome
        Int depth = 50
        Int read_length = 150
        String model = "HSXn"
        Int insert_size = 400
        Int insert_size_sd = 40
        }

    command <<<
        # version
        art_illumina | grep -oE "Version .*" | cut -d " " -f2 > VERSION

        # generate reads
        art_illumina \
        -ss ~{model} \
        -i ~{genome} \
        -p \
        -l ~{read_length} \
        -f ~{depth} \
        -m ~{insert_size} \
        -s ~{insert_size_sd} \
        -o "~{prefix}_R"

        # compress reads
        gzip ~{prefix}_R*.fq
    >>>

    output {
        String version = read_string("VERSION")
        File short_fq1 = "~{prefix}_R1.fq.gz"
        File short_fq2 = "~{prefix}_R2.fq.gz"
    }

    runtime {
        docker: "quay.io/biocontainers/art:2016.06.05--h0704011_13"
        memory: "8 GB"
        cpu: 4
        preemptible: 0
    }
}