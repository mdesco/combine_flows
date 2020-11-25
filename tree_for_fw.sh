#!/usr/bin/env bash
usage() { echo "$(basename $0) [-t tractoflow/results] [-o output]" 1>&2; exit 1; }

while getopts "t:o:" args; do
    case "${args}" in
        t) t=${OPTARG};;
        o) o=${OPTARG};;
        *) usage;;
    esac
done
shift $((OPTIND-1))

if [ -z "${t}" ] || [ -z "${o}" ]; then
    usage
fi

echo "tractoflow results folder: ${t}"
echo "Output folder: ${o}"

echo "Building tree for the following folders:"
cd ${t}
for i in *[!Mean_FRF]; do
    echo $i
    
    mkdir -p $o/$i
    # tractoflow pipeline
    ln -s $t/$i/Register_T1/*mask_warped.nii.gz $o/$i/brain_mask.nii.gz
    ln -s $t/$i/Resample_DWI/*dwi_resampled.nii.gz $o/$i/dwi.nii.gz
    ln -s $t/$i/Eddy_Topup/*bval_eddy $o/$i/bval
    ln -s $t/$i/Eddy_Topup/*bvec $o/$i/bvec

done
echo "Done"

rm -rf $o/$i/Read*

