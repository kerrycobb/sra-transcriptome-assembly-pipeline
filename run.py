#!/usr/bin/env python

import click
import os
import os.path as p

@click.command()
@click.argument('configfile')
@click.option('--snakefile', default=p.join(os.getcwd(), 'Snakefile'))
@click.option('--workdir', default=os.getcwd())
@click.option('--cores', default=20)
@click.option('--latency', default=60)

def cli(snakefile, workdir, configfile, cores, latency):
    configfile = p.abspath(configfile)
    name = p.splitext(p.basename(configfile))[0]
    workdir = p.join(workdir, name)
    if not p.exists(workdir):
        os.makedirs(workdir)

    proc =(
        'qsub '
        '-l nodes=1:ppn=1,mem=250mb,walltime=160:00:00 '
        '-N {name} '
        '-j oe '
        '-m e '
        '-M cobbkerry@gmail.com '
        '-d {workdir} '
        '-o logs/ '
        '-F "{snakefile} {workdir} {configfile} {cores} {latency} {name}" '
        'qsub.sh'
    ).format(
        name=name,
        snakefile=snakefile,
        workdir=workdir,
        configfile=configfile,
        cores=cores,
        latency=latency
        )

    os.system(proc)

if __name__=='__main__':
    cli()
