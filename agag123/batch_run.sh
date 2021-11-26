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

echo "loading  /lustre/nyx/hades/user/mmamaev/install/root-6.18.04-centos7-cxx17/bin/thisroot.sh"
source /lustre/nyx/hades/user/mmamaev/install/root-6.18.04-centos7-cxx17/bin/thisroot.sh

/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build-centos7/src/pre_process -i list.txt -t hades_analysis_tree -o rapidity.root --output-tree-name hades_analysis_tree_extra -n -1 --centrality-file=/lustre/hebe/hades/user/bkardan/param/centrality_epcorr_mar19_ag123ag_2500A_glauber_gen4_2020_10_pass3.root --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_preprocessing/efficiency_files/ag123_proton_2021_09_28.root --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_preprocessing/efficiency_files/ag123_pi_pos_2021_09_28.root --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_preprocessing/efficiency_files/ag123_pi_neg_2021_09_28.root

current_dir=`pwd`
find $current_dir -name "*.root" > rapidity.txt

echo "loading " $ownroot
source $ownroot

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-agag-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AgAg1.58.C --event-cuts hades/agag/1.58/event_cuts/standard
mv correction_out.root correction_in.root

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-agag-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AgAg1.58.C --event-cuts hades/agag/1.58/event_cuts/standard
mv correction_out.root correction_in.root

date $format

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-agag-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AgAg1.58.C --event-cuts hades/agag/1.58/event_cuts/standard

date $format

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-agag-123.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

date $format

rm rapidity.root rapidity.txt correction_in.root

echo JOB FINISHED!