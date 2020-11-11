#!/usr/bin/env bash
usage() { echo "$(basename $0) [-d tractoflow/results] [-o output]" 1>&2; exit 1; }

while getopts "d:o:" args; do
    case "${args}" in
        d) d=${OPTARG};;
        o) o=${OPTARG};;
        *) usage;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ] || [ -z "${o}" ]; then
    usage
fi

echo "tractoflow folder: ${d}"
echo "Output folder: ${o}"

echo "Building tree..."
cd $d
for i in *[!{FRF}]; 
do
   echo $i
   mkdir -p $o/$i

   ln -s ${d}/${i}/Tracking/*.trk ${o}/${i}/
   ln -s ${d}/${i}/DTI_Metrics/*fa.nii.gz ${o}/${i}/
done

rm -rf ${o}/Readme*