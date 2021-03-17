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

while read line; do
  directory=`dirname $line`
  echo $directory/wall_output.root >> wall.txt
done < $filelist
echo >> wall.txt

source /etc/profile.d/modules.sh
module use /cvmfs/it.gsi.de/modulefiles/
module load compiler/gcc/9

echo "loading " $ownroot
source $ownroot

echo

/lustre/nyx/hades/user/mmamaev/hades_rapidity/build/src/rapidity -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1 --tracks-branch mdc_vtx_tracks --out-branch mdc_vtx_tracks_rapidity --efficiency-file=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_protons_botvina.root

current_dir=`pwd`
find $current_dir -name "reco.root" > reco.txt

echo "executing $build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt wall.txt reco.txt -t hades_analysis_tree reconstructed_wall extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-debug.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C"

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt wall.txt reco.txt -t hades_analysis_tree reconstructed_wall extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-debug.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
mv correction_out.root correction_in.root

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt wall.txt reco.txt -t hades_analysis_tree reconstructed_wall extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-debug.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
mv correction_out.root correction_in.root

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt wall.txt reco.txt -t hades_analysis_tree reconstructed_wall extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-debug.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correlation-debug.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

echo JOB FINISHED!