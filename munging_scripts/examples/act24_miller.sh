#!/bin/bash

### task 1 (sedentary / active)

mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f /data/training_data/keyfiles/phase2/act24/task1.csv -j Behavior  \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task1,start,stop' \
    then reorder -f 'Observation,Task1,start,stop' \
    "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" > task1_act24.csv

### task 2 (whole body movement)

subtasks=("2a" "2b" "2c")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
        then filter '$Event_Type == "State start"' \
        then join -f /data/training_data/keyfiles/phase2/act24/task2.csv -j Behavior  \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" \
        > "task${subtask}_act24.csv"
done

### task 3 (intensity)

mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_2,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then put 'if (length($Modifier_2) > 0 && ($Modifier_2 == "light" || $Modifier_2 == "sedentary" || $Modifier_2 == "moderate" || $Modifier_2 == "vigorous")) { $Behavior = $Modifier_2 }' \
    then join -f /data/training_data/keyfiles/phase2/act24/task3.csv -j Behavior  \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task3,start,stop' \
    then reorder -f 'Observation,Task3,start,stop' \
    "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" > task3a_act24.csv

cat task3a_act24.csv | sed 's/moderate/mvpa/g' | sed 's/vigorous/mvpa/g' > task3b_act24.csv

### task 4 (activity type)

subtasks=("4a" "4b")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_3,Event_Type \
        then filter '$Event_Type == "State start"' \
        then put 'if ($Modifier_3 == "\"SP- Trade, Retail, Transportation, and Utilities\"" || $Modifier_3 == "SP- Leisure and Hospiltality" || $Modifier_3 == "SP- Education and Health Services" || $Modifier_3 == "\"SP- Office (business, professional services, finance, info)\"" || $Modifier_3 == "Other") { $Behavior = $Modifier_3 }' \
        then join -f /data/training_data/keyfiles/act24_task${subtask}.csv -j Behavior \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop"  \
        "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" \
        > "task${subtask}_act24.csv"
done

### task 5 (location)

subtasks=("5a" "5b")

for subtask in "${subtasks[@]}"; do
    find "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus" -maxdepth 1 -name '*Locquality*.csv' -print0 | xargs -0 \
        docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type \
        then filter '$Event_Type == "State start"' \
        then join -f /data/training_data/keyfiles/phase2/act24/task5.csv -j Behavior  \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" > "task${subtask}_act24.csv"
done

### task 6 (quality)

find "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus" -maxdepth 1 -name '*Locquality*.csv' -print0 | xargs -0 \ 
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type \
    then filter '$Event_Type == "State start"' \
    then join -f /data/training_data/keyfiles/phase2/act24/task6.csv -j Behavior  \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task6,start,stop' \
    then reorder -f 'Observation,Task6,start,stop' > task6_act24.csv
