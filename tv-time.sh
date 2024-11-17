#!/usr/bin/bash
handle_sigchld() {
    for i in ${!PIDS[@]}; do
        if [ ! -d "/proc/${PIDS[$i]}" ]; then
            wait ${PIDS[$i]}
            CODE=$?
            if [ $CODE -gt 0 ]; then
                echo "Could not get info for ${showNamesArray[$i]}."
            fi
            unset PIDS[$i]
        fi
    done
}

trap handle_sigchld SIGCHLD
INFILE=$1;
mapfile -t showNamesArray < $INFILE
PIDS=();
showLengthsArray=();
for i in ${!showNamesArray[@]}; do
    set -o pipefail
    $GET_TVSHOW_TOTAL_LENGTH_BIN "${showNamesArray[$i]}" | tr -d '\r' > showLength$i &
    PIDS[$i]=$!
done
wait
for i in ${!showNamesArray[@]}; do
    exec 3< showLength$i
    read -r line <&3
    showLengthsArray[$i]=$line
    exec 3<&-
    rm showLength$i
done
i=0;
#find first non-zero show length
while (( $i < ${#showLengthsArray[@]} && showLengthsArray[i] == 0 ))
do
    i=$((i + 1))
done
#if could not get info for any of the shows
if (( $i == ${#showLengthsArray[@]} ))
then
    exit 0;
fi
high=$i
low=$i
while (( i < ${#showLengthsArray[@]} ))
do
    if (( showLengthsArray[i] > showLengthsArray[high] ))
    then
            high=$i
    fi
    if (( showLengthsArray[i] < showLengthsArray[low] && showLengthsArray[i] != 0 ))
    then 
            low=$i
    fi
    i=$((i + 1))
done
lowMinutes=$((showLengthsArray[low]%60));
lowHours=$((showLengthsArray[low]/60));
highMinutes=$((showLengthsArray[high]%60));
highHours=$((showLengthsArray[high]/60));
echo "The shortest show: ${showNamesArray[$low]} (${lowHours}h ${lowMinutes}m)"
echo "The longest show: ${showNamesArray[$high]} (${highHours}h ${highMinutes}m)"