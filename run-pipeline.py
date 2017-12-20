#!/usr/bin/env python

import click
import os
import os.path as p
import yaml

@click.command()
@click.argument('configfile')

def cli(configfile):
    configfile = p.abspath(configfile)
    name = p.splitext(p.basename(configfile))[0]
    workdir = p.join(os.getcwd(), name)
    if not p.exists(workdir):
        os.makedirs(workdir)

    proc =(
        'qsub '
        '-l nodes=1:ppn=1,mem=250mb,walltime=168:00:00 '
        '-N {name} '
        # '-j oe '
        '-m e '
        '-M cobbkerry@gmail.com '
        '-d {workdir} '
        '-F "{configfile} {workdir}" '
        'qsub-command.sh'
    ).format(
        name=name,
        workdir=workdir,
        configfile=configfile,
        )

    os.system(proc)

if __name__=='__main__':
    cli()
