configfile: 'configs/paa_boulengeri.yml'
workdir: '/home/kac0070/frog_trans/paa_boulengeri'

localrules: all
rule all:
    input:
        expand('{sample}/trinity-{sample}/', sample=config['runs']),

#-------------------------------------------------------------------------------
rule ascp:
    output:
        temp('{sample}/{sample}.sra')
    log:
        '{sample}/logs/'
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
rule fqdump:
    input:
        '{sample}/{sample}.sra'
    output:
        temp('{sample}/{sample}_1.fastq'),
        temp('{sample}/{sample}_2.fastq')
    log:
        '{sample}/logs/'
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
rule afterqc:
    input:
        a = '{sample}/{sample}_1.fastq',
        b = '{sample}/{sample}_2.fastq'
    output:
        a = '{sample}/{sample}_1.good.fq',
        b = '{sample}/{sample}_2.good.fq',
        c = temp('{sample}/{sample}_1.bad.fq'),
        d = temp('{sample}/{sample}_2.bad.fq'),
        html = '{sample}/{sample}.afterqc_report.html',
        json = '{sample}/{sample}.afterqc_report.json',
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
# Run CD-HIT-EST on trinity assembly

#-------------------------------------------------------------------------------
# Split chimeras

#-------------------------------------------------------------------------------
# Determine average insert size from trinity assembly

#-------------------------------------------------------------------------------
# Assembly with soap using normalized reads from trinity and avg insert determined from trinity assembly

#-------------------------------------------------------------------------------
# cdHIT EST on Soap assembly

#-------------------------------------------------------------------------------
# Split chimeras

#-------------------------------------------------------------------------------
# bin packer

#-------------------------------------------------------------------------------
# cdHIT EST on bin packer assembly

#-------------------------------------------------------------------------------
# Split chimeras

#-------------------------------------------------------------------------------
# Assembly metrics on soap and trinity if not done yet

#-------------------------------------------------------------------------------
# Pool assembly scaffolds

#-------------------------------------------------------------------------------
# Run transdecoder to split chimeric reads and generate open reading frames
