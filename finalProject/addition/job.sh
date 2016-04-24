#!/bin/bash
#$ -N addition
#$ -S /bin/bash
#$ -q comp541.q
#$ -l gpu=1
##$ -l h_rt=00:05:00 #5 min run
#$ -pe smp 1
#$ -cwd
#$ -o result.out
#$ -e error.err
#$ -M eakyurek13@ku.edu.tr
#$ -m bea

julia copyseq.jl Input.txt

