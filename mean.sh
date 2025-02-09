#!/bin/bash

sum=0
counter=1

until [ $counter -gt 20 ]
do
   sum=$((sum + counter))
   ((counter++))
done

mean=$((sum / 20))

echo "The mean of the first 20 numbers is: $mean"
touch ferary.txt
echo "$sum" > ferary.txt
echo "$mean" >> ferary.txt