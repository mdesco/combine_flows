#!/usr/bin/env bash
usage() { echo "$(basename $0) [-s set-nf results] [-o output-path]" 1>&2; exit 1; }

while getopts "s:o:" args; do
    case "${args}" in
        s) s=${OPTARG};;
        o) o=${OPTARG};;
        *) usage;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${o}" ]; then
    usage
fi

echo "Set-nf results folder: ${s}"
echo "Output folder: ${o}"

echo "Converting *.fib for the following folders:"
cd ${s}
for d in *;	 
do    
    echo ${s}/${d}
    cd $d/F__Surface_Enhanced_Tractography/
    for i in *fib;
    do
	mkdir -p ${o}/$d
	scil_convert_tractogram.py $i ${o}/${d}/${i/.fib/.trk} --reference ../A__Convert_Label_Volume/*__labels.nii.gz
	scil_remove_invalid_streamlines.py ${o}/${d}/${i/.fib/.trk} ${o}/${d}/${i/.fib/_ic.trk} \
					   --remove_single_point \
					   --remove_overlapping_points \
					   --reference ../A__Convert_Label_Volume/*__labels.nii.gz -f
	scil_detect_streamlines_loops.py ${o}/${d}/${i/.fib/_ic.trk} \
					 ${o}/${d}/${i/.fib/_ic_noloop.trk} -a 330  \
					 --reference ../A__Convert_Label_Volume/*__labels.nii.gz -f

    done
    scil_streamlines_math.py concatenate ${o}/${d}/*_ic_noloop.trk ${o}/${d}/set_merged_ic_noloop.trk  -f
    ln -s set_merged_ic_noloop.nii.gz set_final_tracks.trk

    # cleanup 
    rm -rf ${o}/${d}/${i/.fib/}*.trk 

    cd ../../
done

echo "Done"




