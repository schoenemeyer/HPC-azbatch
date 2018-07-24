#!/usr/bin/env bash
impi_version=`ls /opt/intel/impi`
source /opt/intel/impi/${impi_version}/bin64/mpivars.sh

wrf_dir=$AZ_BATCH_APP_PACKAGE_wrf_latest/wrf
hostlist=$AZ_BATCH_HOST_LIST
echo $AZ_BATCH_HOST_LIST >& $HOME/echohostlist
scl enable devtoolset-4 bash

#exit

NUMNODES=$1
PPN=16

NP=$(( $NUMNODES*$PPN ))

echo "NUMNODES=" $NUMNODES "WITH " $NP "CORES PER NODE"
#
pwd
ls $wrf_dir
cd /mnt/resource/batch/tasks/apppackages/wrflatest*
wget https://hpccenth2lts.blob.core.windows.net/wrf/wrfrst_d01_2001-10-25_00_00_00
wget https://hpccenth2lts.blob.core.windows.net/wrf/wrfbdy_d01

export LD_LIBRARY_PATH=./:$LD_LIBRARY_PATH
echo $hostlist
mpirun -np $NP -perhost $PPN -hosts $hostlist  -env I_MPI_FABRICS=shm:dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 -env I_MPI_FALLBACK_DEVICE=0 ./wrf.exe
cd
cp /mnt/resource/batch/tasks/apppackages/wrflatest*/rsl.error.0000 . 
cp /mnt/resource/batch/tasks/apppackages/wrflatest*/stats_$NP.out .  
cat rsl.error.0000 stats_$NP.out

grep 'Timing for main' rsl.error.0000 | tail -149 | awk '{print $9}' | awk -f stats.awk >> stats_$NP.out

if [ -n "$ANALYTICS_WORKSPACE" ]; then
    bash $hpl_dir/linpack_telemetry.sh ../stdout.txt $NUMNODES $PPN
    bash $hpl_dir/upload_log_analytics.sh $ANALYTICS_WORKSPACE LinpackMetrics $ANALYTICS_KEY telemetry.json
fi
az storage blob upload --account-name hpccenth2lts --account-key j.................icwEm9Ig==  --file ./stats_$NP.out -c wrf -n stats_$NP.out
