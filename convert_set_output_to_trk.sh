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
    done
    scil_streamlines_math.py concatenate ${o}/${d}/*trk ${o}/${d}/set_merged_final.trk  -f
    rm -rf ${o}/${d}/${i/.fib/.trk}
    cd ../../
done

echo "Done"


