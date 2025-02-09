#!/bin/bash
sum_of_integers=0
for i in {1..20}
do
    sum_of_integers=$((sum_of_integers + i))
done
mean=$((sum_of_integers / 20))
printf "The sum of the first 20 numbers is: $sum_of_integers\n"
echo "The mean of the first 20 numbers is: $mean"
echo "$sum_of_integers" > lared.txt
echo "$mean" >> lared.txt