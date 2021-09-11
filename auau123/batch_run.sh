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
module load compiler/gcc/9.1.0
module load boost/1.71.0_gcc9.1.0

echo "loading " $ownroot
source $ownroot

#/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build/src/pre_process -i list.txt -t hades_analysis_tree -o rapidity.root --output-tree-name hades_analysis_tree_extra -n -1 --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_protons.root --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_plus.root --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_minus.root
#
#current_dir=`pwd`
#find $current_dir -name "*.root" > rapidity.txt
#
#date $format
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3
#mv correction_out.root correction_in.root
#
#date $format
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3
#mv correction_out.root correction_in.root
#
#date $format
#
#$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree hades_analysis_tree_extra --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3

date $format

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-auau-123.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

#$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-auau-123-proton.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_proton.root

#$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-auau-123-pi-pos.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_pi_pos.root

#$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-auau-123-pi-neg.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_pi_neg.root

date $format

rm rapidity.root rapidity.txt correction_in.root

echo JOB FINISHED!