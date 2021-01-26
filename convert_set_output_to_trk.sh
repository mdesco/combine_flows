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
for i in */F__Surface_Enhanced_Tractography/*fib;
do
    echo $s
    scil_convert_tractogram.py $i ${o}/${i/.fib/.trk} --reference A__Convert_Label_Volume/*__labels.nii.gz
done
scil_streamlines_math.py concatenate ${o}/*trk ${o}/set_merged_final.trk  -f
rm -rf ${o}/${i/.fib/.trk}
echo "Done"

