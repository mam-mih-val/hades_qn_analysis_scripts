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

echo "loading /lustre/nyx/hades/user/mmamaev/install/root-6.18.04/cxx17/bin/thisroot.sh"
source /lustre/nyx/hades/user/mmamaev/install/root-6.18.04/cxx17/bin/thisroot.sh

echo

#/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build/src/pre_process -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1 --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_protons_auau123.root --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_211_au123_dcm_qgsm_smm_2021_04_12.root --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_-211_au123_dcm_qgsm_smm_2021_04_12.root --deutrons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_deutrons_au123_dcm_qgsm_smm_2021_04_12.root
#/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build/src/pre_process -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1 --protons-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_protons.root --pi-plus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_plus.root --pi-minus-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_pi_minus.root
/lustre/nyx/hades/user/mmamaev/hades_preprocessing/build/src/pre_process -i list.txt -t hades_analysis_tree -o reco.root --output-tree-name extra_reco -n -1 --all-efficiency=/lustre/nyx/hades/user/mmamaev/hades_rapidity/efficiency_files/efficiency_all.root

current_dir=`pwd`
find $current_dir -name "*.root" > rapidity.txt

echo "loading /lustre/nyx/hades/user/mmamaev/install/root-6.20.04/bin/thisroot.sh"
source /lustre/nyx/hades/user/mmamaev/install/root-6.20.04/bin/thisroot.sh

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3
mv correction_out.root correction_in.root

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3
mv correction_out.root correction_in.root

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt rapidity.txt -t hades_analysis_tree extra_reco --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-auau-123-all.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C --event-cuts hades/auau/1.23/event_cuts/standard/pt3

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-all.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

echo JOB FINISHED!