#!/bin/env bash

[ ! -z $1 ] && angle=$1 || angle=0
shift
[ ! -z $* ] && device=$* || device="pointer:input-remapper Logitech USB Receiver forwarded"

radians=$(
    echo "scale=66; $angle*(4*a(1)/180)" | \
    bc -l | \
    awk '{printf "%f",$0}'
)

devID=$(xinput list --id-only "${device}")
if [ -z ${devID} ]
then
    xinput list
    exit 1
fi

ctmProp=$(
    xinput list-props ${devID} | \
    grep "Coordinate Transformation Matrix" | \
    awk -F'[()]' '{print $2}'
)
if [ -z ${ctmProp} ]
then
    xinput list-props ${devID}
    exit 1
fi

x1=$(echo $radians | awk '{printf "%f",0+cos($1)}')
x2=$(echo $radians | awk '{printf "%f",0+sin($1)}')
y1=$(echo $radians | awk '{printf "%f",0-sin($1)}')
y2=$(echo $radians | awk '{printf "%f",0+cos($1)}')

echo "New tranform matrix:
[ ${x1}, ${x2}, 0.000000 ]
[ ${y1}, ${y2}, 0.000000 ]
[ 0.000000, 0.000000, 1.000000 ]\
"

xinput set-prop ${devID} ${ctmProp} \
${x1} ${x2} 0.000000 \
${y1} ${y2} 0.000000 \
0.000000 0.000000 1.000000
