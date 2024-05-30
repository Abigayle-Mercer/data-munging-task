#!/bin/bash

### Task 6: Quality (Run First)
find "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus" -maxdepth 1 -name '*Locquality*.csv' -print0 | xargs -0 \ 
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type \
    then filter '$Event_Type == "State start"' \
    then join -f /data/training_data/keyfiles/phase2/act24/task6.csv -j Behavior  \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task6,start,stop' \
    then reorder -f 'Observation,Task6,start,stop' > task6_act24.csv

### Task 1: Sedentary / Active
mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f task6_act24.csv -j Observation -f /data/training_data/keyfiles/phase2/act24/task1.csv -j Behavior  \
    then filter '$Task6 == "high"' \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task1,start,stop' \
    then reorder -f 'Observation,Task1,start,stop' \
    "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" > task1_act24.csv

### Task 2: Whole Body Movement
subtasks=("2a" "2b" "2c")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
        then filter '$Event_Type == "State start"' \
        then join -f task6_act24.csv -j Observation -f /data/training_data/keyfiles/phase2/act24/task2.csv -j Behavior  \
        then filter '$Task6 == "high"' \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" \
        > "task${subtask}_act24.csv"
done

### Task 3: Intensity
mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_2,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f task6_act24.csv -j Observation \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then put 'if (length($Modifier_2) > 0 && ($Modifier_2 == "light" || $Modifier_2 == "sedentary" || $Modifier_2 == "moderate" || $Modifier_2 == "vigorous")) { $Behavior = $Modifier_2 }' \
    then join -f /data/training_data/keyfiles/phase2/act24/task3.csv -j Behavior  \
    then filter '$Task6 == "high"' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task3,start,stop' \
    then reorder -f 'Observation,Task3,start,stop' \
    "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" > task3a_act24.csv

cat task3a_act24.csv | sed 's/moderate/mvpa/g' | sed 's/vigorous/mvpa/g' > task3b_act24.csv

### Task 4: Activity Type
subtasks=("4a" "4b")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_3,Event_Type \
        then filter '$Event_Type == "State start"' \
        then join -f task6_act24.csv -j Observation \
        then put 'if ($Modifier_3 == "\"SP- Trade, Retail, Transportation, and Utilities\"" || $Modifier_3 == "SP- Leisure and Hospiltality" || $Modifier_3 == "SP- Education and Health Services" || $Modifier_3 == "\"SP- Office (business, professional services, finance, info)\"" || $Modifier_3 == "Other") { $Behavior = $Modifier_3 }' \
        then join -f /data/training_data/keyfiles/act24_task${subtask}.csv -j Behavior \
        then filter '$Task6 == "high"' \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop"  \
        "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus/ACT24_directobservationdata_FINAL.csv" \
        > "task${subtask}_act24.csv"
done

### Task 5: Location
subtasks=("5a" "5b")

for subtask in "${subtasks[@]}"; do
    find "/data/Ground_truth_Aim1_skylar/ACT24 Study/noldus" -maxdepth 1 -name '*Locquality*.csv' -print0 | xargs -0 \
        docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type \
        then filter '$Event_Type == "State start"' \
        then join -f task6_act24.csv -j Observation -f /data/training_data/keyfiles/phase2/act24/task5.csv -j Behavior  \
        then filter '$Task6 == "high"' \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" > "task${subtask}_act24.csv"
done

# Train/Test/Evaluation Splits (Assuming a split script or function is used)
# Placeholder for splitting logic
# split_dataset "task1_act24.csv" "task2a_act24.csv" "task2b_act24.csv" "task2c_act24.csv" "task3a_act24.csv" "task3b_act24.csv" "task4a_act24.csv" "task4b_act24.csv" "task5a_act24.csv" "task5b_act24.csv" "task6_act24.csv"

echo "Data processing complete. Remember to implement the split logic for train/test/evaluation."
