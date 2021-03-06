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


current_dir=`pwd`
find $current_dir -name "*.root" > rapidity.txt

$build_dir/QnAnalysisCorrect/QnAnalysisCorrect -i list.txt -t analysis_tree --yaml-config-file=/lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correction-mcini.yml --yaml-config-name=hades_analysis -n -1 --cuts-macro Hades/AuAu1.23.C

$build_dir/QnAnalysisCorrelate/QnAnalysisCorrelate --configuration-file /lustre/nyx/hades/user/mmamaev/QnAnalysis/setups/hades/correlation-mcini.yml --configuration-name _tasks --input-file correction_out.root --input-tree=tree --output-file correlation_out.root

echo JOB FINISHED!