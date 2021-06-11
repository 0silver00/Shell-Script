#!/bin/bash

echo -n "측정 희망시간을 입력하세요(초) : "
read end_time   #측정 희망시간(초) 입력
TEMP=${end_time//[0-9]/}
if [ -z ${end_time} ] || [ -n "$TEMP" ] || [ ${end_time} -le 0 ];
then
	echo "*입력오류*"; exit;
fi

echo -n "측정 간격을 입력하세요(초) : "
read gap_time   #측정 간격(초) 입력
TEMP=${gap_time//[0-9]/}
if [ -z ${gap_time} ] || [ -n "$TEMP" ]  || [ ${gap_time} -le 0 ];
then
	echo "*입력오류*"; exit;
fi

loop=0
end=$(( end_time/gap_time ))

while true;
do
	echo -ne "측정중...\r"
	cpu=$(mpstat | tail -1 | awk '{print 100-$NF}')
	mem=$(sar -r | tail -1 | awk '{print $4}')
	diskTotal=$(df -P | grep -v ^Filesystem | awk '{sum += $2} END { print sum; }')
	diskUsed=$(df -P | grep -v ^Filesystem | awk '{sum += $3} END { print sum; }')
	disk=$(echo "scale=2;100*$diskUsed/$diskTotal" | bc -l)

	echo $(date +"%T"), ${cpu}, ${mem}, ${disk} >> Test_$(date '+%y%m%d').csv

	loop=$(( loop+1 ))
	if [ ${loop} -eq ${end} ]
	then
		echo "측정이 완료되었습니다."
		break
	fi

	sleep ${gap_time}
done