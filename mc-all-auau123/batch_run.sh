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

echo "loading /lustre/nyx/hades/user/mmamaev/install/root-6.18.04-centos7-cxx17/bin/thisroot.sh"
source /lustre/nyx/hades/user/mmamaev/install/root-6.18.04-centos7-cxx17/bin/thisroot.sh

echo

#/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build/src/pre_process -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1 --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_protons.root --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_plus.root --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_minus.root
/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build-centos7/src/pre_process -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1

date $format

echo "loading " $ownroot
source $ownroot

current_dir=`pwd`
find $current_dir -name "*.root" > rapidity.txt

echo "executing $build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C"

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
#mv correction_out.root correction_in.root
#
#date $format
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
#mv correction_out.root correction_in.root
#
#date $format
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C
#
#date $format

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/mc-correlation-all.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

date $format

echo JOB FINISHED!