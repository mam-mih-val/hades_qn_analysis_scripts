#!/bin/bash

n_files=$1
file_list=$2
output_dir=$3

ownroot=/lustre/nyx/hades/user/mmamaev/install/root-6.20.04-centos7-cxx17/bin/thisroot.sh

current_dir=$(pwd)
partition=main
time=8:00:00
build_dir=/lustre/nyx/hades/user/mmamaev/QnAnalysis/build-centos7/src

lists_dir=${output_dir}/lists/
log_dir=${output_dir}/log/

mkdir -p $output_dir
mkdir -p $log_dir
mkdir -p $lists_dir

split -l $n_files -d -a 3 --additional-suffix=.list "$file_list" $lists_dir

n_runs=$(ls $lists_dir/*.list | wc -l)

job_range=1-$n_runs

echo file list=$file_list
echo output_dir=$output_dir
echo log_dir=$log_dir
echo lists_dir=$lists_dir
echo n_runs=$n_runs
echo job_range=$job_range

sbatch --wait \
      -J QnAnalysis \
      -p $partition \
      -t $time \
      -a $job_range \
      -e ${log_dir}/%A_%a.e \
      -o ${log_dir}/%A_%a.o \
      --export=output_dir=$output_dir,file_list=$file_list,ownroot=$ownroot,lists_dir=$lists_dir,build_dir=$build_dir \
      -- /lustre/nyx/hades/user/mmamaev/hades_qn_analysis_scripts/auau123/batch_run.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/nyx/hades/user/mmamaev/install/QnTools/lib
source $ownroot

hadd -j -f $output_dir/correlation_all.root $output_dir/*/correlation_out.root >& $log_dir/log_merge_$STEP.txt

echo JOBS HAVE BEEN COMPLETED!
