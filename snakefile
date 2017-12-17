

localrules: all, concatenate

rule all:
    input:
        expand('trinity-{sample}/', sample=config['runs']),

#-------------------------------------------------------------------------------
# download sra files
rule ascp:
    output:
        temp('{sample}.sra')
    log:
        'logs/'
    threads: 1
    params:
        mem = '1G',
        time = '1:00:00',
        sra_prefix = lambda wildcards: wildcards.sample[:3],
        run_prefix = lambda wildcards: wildcards.sample[:6]
    shell:
        '''
        module load ascp
        ascp -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh \
        -T \
        -k 1 \
        -l 500m \
         \
        anonftp@ftp.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/{params.sra_prefix}/{params.run_prefix}/{wildcards.sample}/{wildcards.sample}.sra \
        {output}
        '''

#-------------------------------------------------------------------------------
# convert sra file to fastq
rule fqdump:
    input:
        '{sample}.sra'
    output:
        temp('{sample}_1.fastq'),
        temp('{sample}_2.fastq')
    log:
        'logs/'
    threads: 1
    params:
        mem = '1G',
        time = '2:00:00'
    shell:
        '''
        module load sratoolkit/2.8.0
        fastq-dump \
        {input} \
        --defline-seq '@$sn[_$rn]/$ri' \
        --split-files \
        --outdir {wildcards.sample}
        '''

#-------------------------------------------------------------------------------
# quality filtering and adapter trimming
rule afterqc:
    input:
        a = '{sample}_1.fastq',
        b = '{sample}_2.fastq'
    output:
        a = '{sample}_1.good.fq',
        b = '{sample}_2.good.fq',
        c = temp('{sample}_1.bad.fq'),
        d = temp('{sample}_2.bad.fq'),
        html = '{sample}.afterqc_report.html',
        json = '{sample}.afterqc_report.json',
    log:
        '{sample}/logs/'
    threads: 1
    params:
        mem = '4G',
        time = '4:00:00'
    shell:
        '''
        module load afterqc
        after.py \
        --read1_file {input.a} \
        --read2_file {input.b} \
        --good_output_folder {wildcards.sample} \
        --bad_output_folder {wildcards.sample} \
        --report_output_folder {wildcards.sample}/reports/
        mv {wildcards.sample}/reports/*.fastq.html {output.html}
        mv {wildcards.sample}/reports/*.fastq.json {output.json}
        '''

#-------------------------------------------------------------------------------
# error correct reads
rule rcorrector:



#-------------------------------------------------------------------------------
# concatenate all reads for each individual and get number of reads for setting assembler memory requiremnets
rule concatenate:



#-------------------------------------------------------------------------------
# Run separate assembly for each individual
# Might be worthwhile to set memory based on number of reads passing filter,
# 1G per million reads is recommended for trinity

rule trinity:
    input:
        a = '{sample}/{sample}_1.good.fq',
        b = '{sample}/{sample}_2.good.fq'
    output:
        '{sample}/trinity-{sample}/'
    log:
        '{sample}/logs/'
    threads: 10
    params:
        mem = '100G',
        time = '100:00:00',
    shell:
        '''
        module load trinity
        Trinity \
        --seqType fq \
        --max_memory {params.mem} \
        --left {input.a} \
        --right {input.b} \
        --KMER_SIZE 32 \
        --CPU {threads} \
        --output {output}
        '''

#-------------------------------------------------------------------------------
rule spades:
    input:
    output:
    log:
    threads:
    params:
    shell:

#-------------------------------------------------------------------------------
rule shannon:
    input:
    output:
    log:
    threads:
    params:
    shell:

#-------------------------------------------------------------------------------
# possibly merge assemblies from multiple individuals
rule orthofuse:
    input:
    output:
    log:
    threads:
    params:
    shell:

#-------------------------------------------------------------------------------
rule detonate:
    input:
    output:
    log:
    threads:
    params:
    shell:

#-------------------------------------------------------------------------------
rule transrate:
    input:
    output:
    log:
    threads:
    params:
    shell:

#-------------------------------------------------------------------------------
rule shmlast:
    input:
    output:
    log:
    threads:
    params:
    shell:

#-------------------------------------------------------------------------------
rule sourmash:
    input:
    output:
    log:
    threads:
    params:
    shell:
