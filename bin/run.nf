#!/usr/bin/env nextflow

params.data = "../results/reads"

Channel
    .fromFilePairs( params.data + '*_{R1,R2}.fastq', size: 2, flat: true)
    .ifEmpty { error "Cannot find any reads matching: ${params.data}" }
    .into { read_pairs_blast,
            read_pairs_centrifuge,
            read_pairs_diamond,
            read_pairs_kaiju,
            read_pairs_kraken,
            read_pairs_kraken2
        }

process blast {
    publishDir "../results/blastn", mode: "copy"

    input:
        set val(id), file(read1), file(read2) from read_pairs_blast

    output:
        file("*_bn_nt.tab") into blast_res_tab

    script:
        """
        blastn -db ../db/blast -evalue 1.0e-5 -out "${id}_R1_bn_nt.tab" \
            -query "${read1}" -outfmt 6 -num_threads "${task.cpus}"

        blastn -db ../db/blast -evalue 1.0e-5 -out "${id}_R2_bn_nt.tab" \
            -query "${read2}" -outfmt 6 -num_threads "${task.cpus}"
        """
}

process centrifuge {
    publishDir "../results/centrifuge", mode: "copy"

    input:
        set val(id), file(read1), file(read2) from read_pairs_centrifuge

    output:
        file("*_report.txt") into centrifuge_report
        file("*.tab") into centrifuge_output

    script:
        """
        centrifuge -x ../db/centrifuge/refseq_bav -1 "${read1}"  -2 "${read2}" \
            --report-file "${id}_report.txt" -S "${id}.tab" -p "${task.cpus}"
        """
}

process diamond {
    publishDir "../results/diamond", mode: "copy"

    input:
        set val(id), file(read1), file(read2) from read_pairs_diamond

    output:
        file("*_dx_tax.tab") into diamond_output

    script:
        """
        diamond blastx -d ../db/diamond/refseq_bav -q "${read1}" \
            -o ${id}_R1_dx_tax.tab -f 102 -p "${task.cpus}"
        diamond blastx -d ../db/diamond/refseq_bav -q "${read2}" \
            -o ${id}_R2_dx_tax.tab -f 102 -p "${task.cpus}"
        """
}

process kaiju {
    publishDir "../results/kaiju", mode: "copy"

    input:
        set val(id), file(read1), file(read2) from read_pairs_kaiju

    output:
        file("*.tab") into kaiju_output
        file("*_sp_sum.txt") into kaiju_report

    script:
        """
        kaiju -t ../db/taxonomy/nodes.dmp -f ../db/kaiju/refseq_bav.fmi \
            -i "${read1}" -j "${read2}" -o "${id}.tab" -z "${task.cpus}"
        kaijuReport -t ../db/taxonomy/nodes.dmp -n ../db/taxonomy/names.dmp \
            -i "${id}.tab" -r species -o "${id}_sp_sum.txt"
        """
}

process kraken {
    publishDir "../results/kraken", mode: "copy"

    input:
        set val(id), file(read1), file(read2) from read_pairs_kraken

    output:
        file("*.tab") into kraken_output
        file("*_report.txt") into kraken_report

    script:
        """
        kraken --preload --db ../db/kraken/refseq_bav --output "${id}.tab" \
            --fastq-input --threads "${task.cpus}" \
            --paired "${read1}" "${read2}"
        kraken-report --db ../db/kraken/refseq_bav "${id}.tab" > "${id}_report.txt"
        """
}

process kraken2 {
    publishDir "../results/kraken2", mode: "copy"

    input:
        set val(id), file(read1), file(read2) from read_pairs_kraken2

    output:
        file("*.tab") into kraken2_output
        file("*_report.txt") into kraken2_report

    script:
        """
        kraken2 --db ../db/kraken2/refseq_bav --output "${id}.tab" \
            --fastq-input --threads "${task.cpus}" \
            --report "${id}_report.txt"
            --paired "${read1}" "${read2}"
        """
}
