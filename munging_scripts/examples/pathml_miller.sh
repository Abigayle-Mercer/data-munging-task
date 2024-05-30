#!/bin/bash

### task 1 (sedentary / active)

find "/data/Ground_truth_Aim1_skylar/PathML Study/Beh_Posture_noldus" -name 'PathML*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f /data/training_data/keyfiles/phase2/pathml/task1.csv -j Behavior  \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task1,start,stop' \
    then reorder -f 'Observation,Task1,start,stop' > task1_pathml.csv

### task2:


subtasks=("2a" "2b" "2c")

for subtask in "${subtasks[@]}"; do

find "/data/Ground_truth_Aim1_skylar/PathML Study/Beh_Posture_noldus" -name 'PathML*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
        then filter '$Event_Type == "State start"' \
        then join -f /data/training_data/keyfiles/phase2/pathml/task2.csv -j Behavior  \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        > "task${subtask}_pathml.csv"
done

# task3:

find "/data/Ground_truth_Aim1_skylar/PathML Study/Beh_Posture_noldus" -name 'PathML*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_1,Modifier_2,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then put 'if (length($Modifier_1) > 0 && ($Modifier_1 == "light" || $Modifier_1 == "sedentary" || $Modifier_1 == "moderate" || $Modifier_1 == "vigorous")) { $Behavior = $Modifier_1 }' \
    then put 'if (length($Modifier_2) > 0 && ($Modifier_2 == "light" || $Modifier_2 == "sedentary" || $Modifier_2 == "moderate" || $Modifier_2 == "vigorous")) { $Behavior = $Modifier_2 }' \
    then join -f /data/training_data/keyfiles/phase2/pathml/task3.csv -j Behavior  \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task3,start,stop' \
    then reorder -f 'Observation,Task3,start,stop' > task3a_pathml.csv

cat task3a_pathml.csv | sed 's/moderate/mvpa/g' | sed 's/vigorous/mvpa/g' > task3b_pathml.csv

### task 4 (activity type)

subtasks=("4a" "4b")

for subtask in "${subtasks[@]}"; do
    find "/data/Ground_truth_Aim1_skylar/PathML Study/Beh_Posture_noldus" -name 'PathML*.csv' -print0 | xargs -0 \
        docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_2,Event_Type' \
        then filter '$Event_Type == "State start"' \
        then put 'if (length($Modifier_2) > 0 && ($Modifier_2 == "SP- Leisure and Hospiltality" || $Modifier_2 == "\"SP- Office (business, professional services, finance, info)\"")) { $Behavior = $Modifier_2 }' \
        then join -f /data/training_data/keyfiles/phase2/pathml/task4.csv -j Behavior  \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop"  \
        > "task${subtask}_pathml.csv"
done

#task5:

subtasks=("5a" "5b")

for subtask in "${subtasks[@]}"; do
    find "/data/Ground_truth_Aim1_skylar/PathML Study/Location_Quality_noldus" -name 'PathML*.csv' -print0 | xargs -0 \
        docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
        then filter '$Event_Type == "State start"' \
        then join -f /data/training_data/keyfiles/phase2/pathml/task5.csv -j Behavior  \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" > "task${subtask}_pathml.csv"
done

#task6:

find "/data/Ground_truth_Aim1_skylar/PathML Study/Location_Quality_noldus" -name 'PathML*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f 'Observation,Time_Relative_sf,Duration_sf,Modifier_1,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f /data/training_data/keyfiles/phase2/pathml/task6.csv -j Modifier_1  \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f "Observation,Task6,start,stop" \
    then reorder -f "Observation,Task6,start,stop" > "task6_pathml.csv"

