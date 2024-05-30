#!/bin/bash

### Task 6: Quality (Run First)
mlr --csv cut -f Observation,Time_Relative_f,Behavior,Event_Type \
    then filter '$Event_Type == "State start"' \
    then join -f /data/training_data/keyfiles/phase2/am/task6.csv -j Behavior  \
    then put '$start = $Time_Relative_f / 60' \
    then put '$stop = $Time_Relative_f / 60 + 1' \
    then cut -f 'Observation,Task6,start,stop' \
    then reorder -f 'Observation,Task6,start,stop' \
    "/data/Ground_truth_Aim1_skylar/AM Study/AM_GT_Quality_Formatted-Copy1.csv" \
    > task6_am.csv

### Task 1: Sedentary / Active
mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f "/data/Ground_truth_Aim1_skylar/AM Study/noldus/observations.csv" -j Observation \
    then join -f task6_am.csv -j Observation -f /data/training_data/keyfiles/phase2/am/task1.csv -j Behavior  \
    then filter '$Task6 == "high"' \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task1,start,stop' \
    then reorder -f 'Observation,Task1,start,stop' \
    "/data/Ground_truth_Aim1_skylar/AM Study/noldus/best_obs_onesheet.csv" > task1_am.csv

### Task 2: Whole Body Movement
subtasks=("2a" "2b" "2c")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Event_Type' \
        then filter '$Event_Type == "State start"' \
        then join -f "/data/Ground_truth_Aim1_skylar/AM Study/noldus/observations.csv" -j Observation \
        then join -f task6_am.csv -j Observation -f /data/training_data/keyfiles/phase2/am/task2.csv -j Behavior  \
        then filter '$Task6 == "high"' \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        "/data/Ground_truth_Aim1_skylar/AM Study/noldus/best_obs_onesheet.csv" \
        > "task${subtask}_am.csv"
done

### Task 3: Intensity
mlr --csv cut -f 'Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_3,Event_Type' \
    then filter '$Event_Type == "State start"' \
    then join -f "/data/Ground_truth_Aim1_skylar/AM Study/noldus/observations.csv" -j Observation \
    then join -f task6_am.csv -j Observation \
    then put '$stop = $Time_Relative_sf + $Duration_sf' \
    then put 'if (length($Modifier_3) > 0 && ($Modifier_3 == "light" || $Modifier_3 == "sedentary" || $Modifier_3 == "moderate" || $Modifier_3 == "vigorous")) { $Behavior = $Modifier_3 }' \
    then join -f /data/training_data/keyfiles/phase2/am/task3.csv -j Behavior  \
    then filter '$Task6 == "high"' \
    then rename 'Time_Relative_sf,start' \
    then cut -f 'Observation,Task3,start,stop' \
    then reorder -f 'Observation,Task3,start,stop' \
    "/data/Ground_truth_Aim1_skylar/AM Study/noldus/best_obs_onesheet.csv" > task3a_am.csv

cat task3a_am.csv | sed 's/moderate/mvpa/g' | sed 's/vigorous/mvpa/g' > task3b_am.csv

### Task 4: Activity Type
subtasks=("4a" "4b")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f Observation,Time_Relative_sf,Duration_sf,Behavior,Modifier_4,Event_Type \
        then filter '$Event_Type == "State start"' \
        then join -f "/data/Ground_truth_Aim1_skylar/AM Study/noldus/observations.csv" -j Observation \
        then join -f task6_am.csv -j Observation \
        then put 'if ($Modifier_4 == "SP- Education and Health Services" || $Modifier_4 == "\"SP- Office (business, professional services, finance, info)\"") { $Behavior = $Modifier_4 }' \
        then join -f /data/training_data/keyfiles/phase2/am/task4.csv -j Behavior \
        then filter '$Task6 == "high"' \
        then put '$stop = $Time_Relative_sf + $Duration_sf' \
        then rename 'Time_Relative_sf,start' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop"  \
        "/data/Ground_truth_Aim1_skylar/AM Study/noldus/best_obs_onesheet.csv" \
        > "task${subtask}_am.csv"
done

### Task 5: Location
subtasks=("5a" "5b")

for subtask in "${subtasks[@]}"; do
    mlr --csv cut -f Observation,Time_Relative_f,Behavior,Event_Type \
        then filter '$Event_Type == "State start"' \
        then join -f task6_am.csv -j Observation -f /data/training_data/keyfiles/phase2/am/task5.csv -j Behavior  \
        then filter '$Task6 == "high"' \
        then put '$start = $Time_Relative_f / 60' \
        then put '$stop = $Time_Relative_f / 60 + 1' \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        "/data/Ground_truth_Aim1_skylar/AM Study/AM_GT_Location_Formatted-Copy1.csv" \
        > "task${subtask}_am.csv"
done

# Train/Test/Evaluation Splits (Assuming a split script or function is used)
# Placeholder for splitting logic
# split_dataset "task1_am.csv" "task2a_am.csv" "task2b_am.csv" "task2c_am.csv" "task3a_am.csv" "task3b_am.csv" "task4a_am.csv" "task4b_am.csv" "task5a_am.csv" "task5b_am.csv" "task6_am.csv"

echo "Data processing complete. Remember to implement the split logic for train/test/evaluation."
