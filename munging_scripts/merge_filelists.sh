#!/bin/bash

# Check if a task number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <task_number>"
  exit 1
fi

TASK_NUMBER=$1

mlr --csv \
    grep -v "GPRO|private" then \
    grep -v "ID_126_01|ID_134_02|ID_136_02|ID_138_02|ID_139_02|ID_144_01|ID_144_02|ID_150_02|AM07DO1|AM11DO2|AM15DO1|AM27DO1|PathML_behposture|PathML_PID04_GPRO_Behposture_KY|PathML_PID07_GPRO_BehPosture_HS_HS|PathML_PID07_GPRO_Behposture_KY_HS|AM08DO1_J_copyB_FINAL_R|AM11DO2_R_copyB_FINAL_C|AM15DO2_M_copyA_FINAL_C|AM24DO2_M_FINAL_R|AM26DO2_R_copyA_FINAL_C" then \
    put -S '
      if (\$Observation == "AM15DO2") {
        \$Observation = "AM15DO2_reedit";
      }

      \$Observation = gsub(\$Observation, " ", "_");

      if (\$Observation =~ "^ID_.*") {
        \$Observation = gsub(\$Observation, "^ID_", "ID");
        \$Observation = gsub(\$Observation, "_", "-");
        \$Observation = substr1(\$Observation, 1, strlen(\$Observation) - 2);
      }
      elif (\$Observation =~ "^AM.*") {
        \$Observation = "GP_" . sub(\$Observation, "_.*", "");
      }
      elif (\$Observation =~ "^[Pp].*") {
        \$Observation = "PathML_" . substr1(\$Observation, 8, strlen(\$Observation));
        \$Observation = gsub(\$Observation, "PRO.*", "Pro");
        \$Observation = gsub(\$Observation, "D0", "D");
      }

      \$Observation = "/mnt/ephemeral/fps2_384/" . \$Observation . ".mp4";

      \$start = ceil(\$start);
      \$stop = floor(\$stop);

      # some Surface Pros are broken, use GPro as a fallback
      if (\$Observation =~ ".*PID[67]_S.*" || \$Observation =~ ".*PID15_S.*") {
        \$Observation = gsub(\$Observation, "SPro", "GPro");
      }
      ' \
    then filter '\$stop > \$start' \
    /data/training_data/filelists/phase2/task${TASK_NUMBER}*.csv | tail -n +2 | sed 's/,/ /g' > task${TASK_NUMBER}_filelist.txt 

cat task${TASK_NUMBER}_filelist.txt | cut -d' ' -f2 | sort | uniq > task${TASK_NUMBER}_unique_classes.txt 
awk -F, '{print $1, NR-1}' task${TASK_NUMBER}_unique_classes.txt > task${TASK_NUMBER}_class_to_int_mapping.txt
awk 'BEGIN{FS=" "; OFS=" "} NR==FNR{class[$1]=$2; next} FNR>1{print $1, class[$2], $3, $4}' task${TASK_NUMBER}_class_to_int_mapping.txt task${TASK_NUMBER}_filelist.txt  > task${TASK_NUMBER}_filelist_final.txt 
rm task${TASK_NUMBER}_unique_classes.txt task${TASK_NUMBER}_filelist.txt
