#!/bin/bash

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SLURM_ARRAY_TASK_ID))

filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

while read line; do
    echo $line >> list.txt
done < $filelist
echo >> list.txt

source /etc/profile.d/modules.sh
module use /cvmfs/it.gsi.de/modulefiles/
module load compiler/gcc/9

echo "loading " $ownroot
source $ownroot

echo

/lustre/nyx/hades/user/mmamaev/hades_rapidity/build/src/rapidity -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1 --tracks-branch mdc_vtx_tracks --out-branch mdc_vtx_tracks_rapidity --config-directory /lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files

/lustre/nyx/hades/user/mmamaev/hades_rapidity/build/src/rapidity -i list.txt -t hades_analysis_tree -o sim.root --output-tree-name extra_sim -n -1 --tracks-branch sim_tracks --out-branch sim_tracks_rapidity --config-directory /lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files

current_dir=`pwd`
find $current_dir -name "reco.root" > reco.txt

current_dir=`pwd`
find $current_dir -name "sim.root" > sim.txt

#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt reco.txt sim.txt -t hades_analysis_tree extra_reco extra_sim --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
#mv correction_out.root correction_in.root
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt reco.txt sim.txt -t hades_analysis_tree extra_reco extra_sim --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
#mv correction_out.root correction_in.root
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt reco.txt sim.txt -t hades_analysis_tree extra_reco extra_sim --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correlation.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

echo JOB FINISHED!