#!/bin/bash

# This script creates 30 files stored in 3 diffrent child dit=rectoriesin ib the parent directory

num_files=10

# Base names for the files
base_name_txt="file_txt"
base_name_log="file_log"
base_name_cfg="file_cfg"

# Create the directories

mkdir -p LANCER/txt LANCER/log LANCER/cfg

echo "Directories have been successfully created."

# Create the .txt files
for ((i=1; i<=num_files; i++))
do
   touch "LANCER/txt/${base_name_txt}_${i}.txt"
   echo "Created LANCER/txt/${base_name_txt}_${i}.txt"
done

# Create the .log files
for ((i=1; i<=num_files; i++))
do
   touch "LANCER/log/${base_name_log}_${i}.log"
   echo "Created LANCER/log/${base_name_log}_${i}.log"
done

# Create the .cfg files
for ((i=1; i<=num_files; i++))
do
   touch "LANCER/cfg/${base_name_cfg}_${i}.cfg"
   echo "Created LANCER/cfg/${base_name_cfg}_${i}.cfg"
done

echo "Completed creating $num_files files of each type."
