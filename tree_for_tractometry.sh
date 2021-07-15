#!/usr/bin/env bash
usage() { echo "$(basename $0) [-r RBX] [-t tractoflow/results] [-o output]" 1>&2; exit 1; }

while getopts "r:t:o:" args; do
    case "${args}" in
        r) r=${OPTARG};;
        t) t=${OPTARG};;
        o) o=${OPTARG};;
        *) usage;;
    esac
done
shift $((OPTIND-1))

if [ -z "${r}" ] || [ -z "${t}" ] || [ -z "${o}" ]; then
    usage
fi

echo "rbx_flow results folder: ${r}"
echo "tractoflow results folder: ${t}"
echo "Output folder: ${o}"


echo "Building tree for the following folders:"
cd ${r}
for i in *[!{Average_Bundles}];
do
    echo $i
    mkdir -p $o/$i/bundles
    mkdir -p $o/$i/metrics

    # if centroids are there, create dir
    if [ -d "$r/$i/Transform_Centroids/" ]
    then
	mkdir -p $o/$i/centroids
	ln -s $r/$i/Transform_Centroids/*.trk $o/$i/centroids/
    fi
    
    # RBX results
    for f in $r/$i/Clean_Bundles/*cleaned.trk;
    do
	name=${f/*Clean_Bundles\//}
	ln -s $f $o/$i/bundles/${name/_m_cleaned.trk/.trk}
    done
    
    # tractoflow metrics
    ln -s $t/$i/DTI_Metrics/*fa.nii.gz $o/$i/metrics/fa.nii.gz
    ln -s $t/$i/DTI_Metrics/*ad.nii.gz $o/$i/metrics/ad.nii.gz
    ln -s $t/$i/DTI_Metrics/*md.nii.gz $o/$i/metrics/md.nii.gz
    ln -s $t/$i/DTI_Metrics/*rd.nii.gz $o/$i/metrics/rd.nii.gz
    ln -s $t/$i/FODF_Metrics/*afd_total.nii.gz $o/$i/metrics/afd_total.nii.gz
    ln -s $t/$i/FODF_Metrics/*nufo.nii.gz $o/$i/metrics/nufo.nii.gz
done
echo "Done"
