#!/bin/bash

### task 1 (sedentary / active)

find "/data/Ground_truth_Aim1/Wisconsin/noldus" -name '*POSTURE*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f 'study,subject,visit,posture_surface_noldus' \
    then put -S '$Observation = $study . "_" . $subject . "_" . $visit' \
    then put '
        begin { @nr1 = 0; @Observation = null; }
        if (@Observation == $Observation) {
            @nr1 += 1;   
        }
        else {
            @nr1 = 0;
            @Observation = $Observation;
        }

        $start = @nr1; 
        $stop = $start + 1
    ' \
    then join -f /data/training_data/keyfiles/phase2/wisc/task1.csv -j posture_surface_noldus  \
    then cut -f 'Observation,Task1,start,stop' \
    then reorder -f 'Observation,Task1,start,stop' \
    > task1_wisc.csv

### task 2 (whole body movement)

subtasks=("2a" "2b" "2c")

for subtask in "${subtasks[@]}"; do
    find "/data/Ground_truth_Aim1/Wisconsin/noldus" -name '*POSTURE*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f 'study,subject,visit,posture_surface_noldus' \
        then put -S '$Observation = $study . "_" . $subject . "_" . $visit' \
        then put '
            begin { @nr1 = 0; @Observation = null; }
            if (@Observation == $Observation) {
                @nr1 += 1;   
            }
            else {
                @nr1 = 0;
                @Observation = $Observation;
            }

            $start = @nr1; 
            $stop = $start + 1
        ' \
        then join -f /data/training_data/keyfiles/phase2/wisc/task2.csv -j posture_surface_noldus  \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        > "task${subtask}_wisc.csv"
done

### task 3 (intensity)

find "/data/Ground_truth_Aim1/Wisconsin/noldus" -name '*POSTURE*.csv' -print0 | xargs -0 \
    docker run --rm -v /data:/data jauderho/miller --csv \
    cut -f 'study,subject,visit,intensity_surface_noldus' \
    then put -S '$Observation = $study . "_" . $subject . "_" . $visit' \
    then put '
        begin { @nr1 = 0; @Observation = null; }
        if (@Observation == $Observation) {
            @nr1 += 1;   
        }
        else {
            @nr1 = 0;
            @Observation = $Observation;
        }

        $start = @nr1; 
        $stop = $start + 1
    ' \
    then join -f /data/training_data/keyfiles/phase2/wisc/task3.csv -j intensity_surface_noldus  \
    then cut -f 'Observation,Task3,start,stop' \
    then reorder -f 'Observation,Task3,start,stop' \
    | sed 's/moderate/mvpa/g' > task3b_wisc.csv

### task 4

subtasks=("4a" "4b")

for subtask in "${subtasks[@]}"; do
    find "/data/Ground_truth_Aim1/Wisconsin/noldus" -name '*ACTIVITY*.csv' -print0 | xargs -0 \
        docker run --rm -v /data:/data jauderho/miller --csv \
        cut -f 'study,subject,visit,behavior_surface_noldus,activity_surface_noldus' \
        then put -S '$Observation = $study . "_" . $subject . "_" . $visit' \
        then put '
            begin { @nr1 = 0; @Observation = null; }
            if (@Observation == $Observation) {
                @nr1 += 1;   
            }
            else {
                @nr1 = 0;
                @Observation = $Observation;
            }

            $start = @nr1; 
            $stop = $start + 1
        ' \
        then join --ul --lp activity_ -j activity_surface_noldus -f /data/training_data/keyfiles/phase2/wisc/task4_activity.csv \
        then join --ul --lp behavior_ -j behavior_surface_noldus -f /data/training_data/keyfiles/phase2/wisc/task4_behavior.csv \
        then put -S "\$Task${subtask} = length(\$behavior_Task${subtask}) > 0 ? \$behavior_Task${subtask} : length(\$activity_Task${subtask}) > 0 ? \$activity_Task${subtask} : null" \
        then filter -S "\$Task${subtask} != null" \
        then cut -f "Observation,Task${subtask},start,stop" \
        then reorder -f "Observation,Task${subtask},start,stop" \
        > "task${subtask}_wisc.csv"
done