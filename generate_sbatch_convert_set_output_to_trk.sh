

# $1 : path to Subject ID in SET results folder
#
# e.g. ./convert_set_to_trk_for_commit.sh 100307 


echo $1
cd $1/F_*

for i in *.fib;
do
    echo ${i};
    echo scil_remove_invalid_streamlines.py ${i} ${i/.fib/_ic.trk} --remove_single_point --remove_overlapping_points --reference  ../A__Convert_Label_Volume/*__labels.nii.gz >> cmd.sh;
done
parallel -P 8 < cmd.sh
rm cmd.sh

for i in *_ic.trk;
do
    echo ${i};
    echo scil_detect_streamlines_loops.py ${i} ${i/.trk/_noloops.trk} -a 330 >> cmd.sh;
done
parallel -P 8 < cmd.sh
rm cmd.sh

scil_streamlines_math.py concatenate *_noloops.trk set_merged_tracks_ic_noloops.trk
ln -s set_merged_tracks_ic_noloops.trk set_final_tracks.trk


# TODO
# cleanup if set_merged_tracks_ic_noloops.trk exists. rm -rf *ic.trk *noloops.trk


cd ../../


# TODO
# genereate de sbatch cmd.sh directly to do this for all subjects in the results directory?
#    with proper CPU numner, i.e. 40 and 185RAM for a node of beluga
#    with proper email

for a in input/*;
do
    s1=""

    s1+='#!/bin/sh'$'\n\n'
    s1+="#SBATCH --mail-user=maxime.descoteaux@gmail.com"$'\n'
    s1+="#SBATCH --mail-type=BEGIN"$'\n'
    s1+="#SBATCH --mail-type=END"$'\n'
    s1+="#SBATCH --mail-type=FAIL"$'\n'
    s1+="#SBATCH --mail-type=REQUEUE"$'\n'
    s1+="#SBATCH --mail-type=ALL"$'\n\n'

    s1+="#SBATCH --nodes=1"$'\n'
    s1+="#SBATCH --cpus-per-task=40"$'\n'
    s1+="#SBATCH --mem=185G"$'\n'
    s1+="#SBATCH --time=10:00:00"$'\n\n'

    s1+="export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)"$'\n\n'
    
    s1+="mkdir -p ${a/*input\//}"$'\n'
    s1+="cp nextflow.config beluga.conf ${a/*input\//}"$'\n'
    s1+="cd ${a/*input\//}"$'\n'
    s1+="nextflow-20.04.1-all -c beluga.conf run /lustre04/scratch/descotea/Sami_Controls/output_set_individual/set_alpha10v0/set-nf/main.nf  --tractoflow /lustre04/scratch/descotea/Sami_Controls/output_set_individual/${a}/tractoflow --surfaces /lustre04/scratch/descotea/Sami_Controls/output_set_individual/${a}/civet/ -profile civet2_dkt -with-singularity /lustre04/scratch/descotea/Sami_Controls/output_set_individual/set_alpha10v0/set_alpha10v0.img --processes 40 --minimum_length 5 --maximum_length 200 -resume -with-mpi -with-report report.html"$'\n'
    s1+="cd ../"$'\n'
    echo "$s1" > ${a/*input\//}.sh;
    
    s2+="sbatch ${a/*input\//}.sh"$'\n'
done







