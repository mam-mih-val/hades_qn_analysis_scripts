#!/bin/bash

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SLURM_ARRAY_TASK_ID))

filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

echo "loading  /lustre/nyx/hades/user/mmamaev/install/root-6.18.04-centos7-cxx17/bin/thisroot.sh"
source /lustre/nyx/hades/user/mmamaev/install/root-6.18.04-centos7-cxx17/bin/thisroot.sh

/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build-centos7/src/pre_process -i $filelist -t hades_analysis_tree -o rapidity.root --output-tree-name hades_analysis_tree_extra -n 1000 --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_preprocessing/efficiency_files/au123_proton_2021_09_28.root --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_preprocessing/efficiency_files/au123_pi_pos_2021_09_28.root --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_preprocessing/efficiency_files/au123_pi_neg_2021_09_28.root

current_dir=`pwd`
find $current_dir -name "*.root" > rapidity.txt

echo "loading " $ownroot
source $ownroot

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i $filelist rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123.yml --yaml-config-name=hades_analysis -n 1000 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3
mv correction_out.root correction_in.root

#date $format

#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i $filelist rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123.yml --yaml-config-name=hades_analysis -n 1000 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3
#mv correction_out.root correction_in.root

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i $filelist rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123.yml --yaml-config-name=hades_analysis -n 1000 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3

date $format

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-auau-123.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

date $format

rm rapidity.root rapidity.txt correction_in.root correction_out.root

echo JOB FINISHED!