version 1.0

task pad_genome {
    input {
        File genome
    }

    command <<<
        python <<CODE
        import sys
        def pad_circular_genome(input_fasta, output_fasta, pad_length=20000):
            with open(input_fasta, 'r') as infile, open(output_fasta, 'w') as outfile:
                header = ""
                sequence = []
                
                for line in infile:
                    line = line.strip()
                    if line.startswith(">"):
                        # Process the previous sequence block before moving to the next header
                        if header:
                            seq_str = "".join(sequence)
                            actual_pad = min(pad_length, len(seq_str) // 2) # Prevent padding over 50% for tiny plasmids
                            padded_seq = seq_str + seq_str[:actual_pad]
                            outfile.write(f"{header}\n{padded_seq}\n")
                        header = line
                        sequence = []
                    else:
                        sequence.append(line)
                        
                # Process the very last sequence block in the file
                if header:
                    seq_str = "".join(sequence)
                    actual_pad = min(pad_length, len(seq_str) // 2)
                    padded_seq = seq_str + seq_str[:actual_pad]
                    outfile.write(f"{header}\n{padded_seq}\n")

        pad_circular_genome("~{genome}", "padded_genome.fasta")
        print("Genome padding completed successfully.")
        CODE
    >>>

    output {
        File padded_genome = "padded_genome.fasta"
    }

    runtime {
        docker: "python:3.11.15-slim"
        memory: "1 GB"
        cpu: 1
        preemptible: 0
    }
}