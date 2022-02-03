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

echo "loading " $ownroot
source $ownroot

echo

date $format

/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build-centos7/src/pre_process -i list.txt \
                                                                                -t hades_analysis_tree \
                                                                                -o reco.root \
                                                                                --output-tree-name extra_reco \
                                                                                -n -1 \
                                                                                --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_protons.root \
                                                                                --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_plus.root \
                                                                                --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_minus.root

current_dir=`pwd`
find $current_dir -name "reco.root" > reco.txt

date $format

echo "executing $build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt wall.txt reco.txt -t hades_analysis_tree reconstructed_wall extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C"

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt wall.txt reco.txt \
                                              -t hades_analysis_tree reconstructed_wall extra_reco \
                                              --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123-wall.yml \
                                              --yaml-config-name=hades_analysis \
                                              -n -1 \
                                              --cuts-macro Hades/AuAu1.23.C
#mv correction_out.root correction_in.root

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correlation-auau-123-wall.yml \
                                                  --configuration-name _tasks \
                                                  --input-file correction_out.root \
                                                  --input-tree=tree \
                                                  --output-file correlation_out.root

rm reco.root wall.txt list.txt

date $format

echo JOB FINISHED!