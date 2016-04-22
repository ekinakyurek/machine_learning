#!/bin/bash
#$ -N rnn4
#$ -S /bin/bash
#$ -q comp541.q
#$ -l gpu=1
##$ -l h_rt=00:05:00 #5 min run
#$ -pe smp 1
#$ -cwd
#$ -o rnn4.out
#$ -e rnn4.err
#$ -M eakyurek13@ku.edu.tr
#$ -m bea

julia NoMaskMemorization.jl Input.txt

