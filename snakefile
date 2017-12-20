# configfile: 'configs/E_coli.yml'

localrules: all

rule all:
    input:
        expand('{run}_1.good.fq', run=config['runs']),
        expand('{run}_2.good.fq', run=config['runs'])

#-------------------------------------------------------------------------------
rule ascp:
    output:
        temp('{run}.sra')
    log:
        'logs/'
    threads: 1
    params:
        mem = '1G',
        time = '1:00:00',
        sra_prefix = lambda wildcards: wildcards.run[:3],
        run_prefix = lambda wildcards: wildcards.run[:6]
    shell:
        '''
        module load ascp
        ascp -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh \
        -T \
        -k 1 \
        -l 500m \
         \
        anonftp@ftp.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/{params.sra_prefix}/{params.run_prefix}/{wildcards.run}/{wildcards.run}.sra \
        {output}
        '''

#-------------------------------------------------------------------------------
rule fqdump:
    input:
        '{run}.sra'
    output:
        temp('{run}_1.fastq'),
        temp('{run}_2.fastq')
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
        '''

#-------------------------------------------------------------------------------
rule afterqc:
    input:
        a = '{run}_1.fastq',
        b = '{run}_2.fastq'
    output:
        a = '{run}_1.good.fq',
        b = '{run}_2.good.fq',
        c = temp('{run}_1.bad.fq'),
        d = temp('{run}_2.bad.fq'),
    log:
        'logs/'
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
        '''

#-------------------------------------------------------------------------------
# rule rcorrector:







# #-------------------------------------------------------------------------------
# # concatenate all reads for each individual and get number of reads for setting assembler memory requiremnets
# rule concatenate:
#
#
#
# #-------------------------------------------------------------------------------
# # Run separate assembly for each individual
# # Might be worthwhile to set memory based on number of reads passing filter,
# # 1G per million reads is recommended for trinity
#
# rule trinity:
#     input:
#         a = '{sample}/{sample}_1.good.fq',
#         b = '{sample}/{sample}_2.good.fq'
#     output:
#         '{sample}/trinity-{sample}/'
#     log:
#         '{sample}/logs/'
#     threads: 10
#     params:
#         mem = '100G',
#         time = '100:00:00',
#     shell:
#         '''
#         module load trinity
#         Trinity \
#         --seqType fq \
#         --max_memory {params.mem} \
#         --left {input.a} \
#         --right {input.b} \
#         --KMER_SIZE 32 \
#         --CPU {threads} \
#         --output {output}
#         '''
