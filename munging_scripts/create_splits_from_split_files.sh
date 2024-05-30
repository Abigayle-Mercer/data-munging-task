#!/bin/bash

# Check if three arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <input_file> <output_prefix> <keyfile> <fps>"
    exit 1
fi

input_file="$1" # The first argument is the input file name
output_prefix="$2" # The second argument is the prefix for output files
keyfile="$3" # The third argument is the keyfile to split
fps="$4" # The fourth argument is the fps of the videos in the studies

# Function to extract paths, remove quotes and commas, and convert to newline-delimited format
extract_and_format() {
    fold=$1
    grep "^$fold:" "$input_file" | \
    sed -e 's/^.*: \[\(.*\)\]$/\1/' -e 's/", "/\n/g' -e 's/"//g'
}

# Extract and format paths for each fold
extract_and_format "Training" > "${output_prefix}_training_paths.txt"
extract_and_format "Testing" > "${output_prefix}_testing_paths.txt"
extract_and_format "Evaluation" > "${output_prefix}_evaluation_paths.txt"

mkdir -p "${output_prefix}"

for fold in "training" "testing" "evaluation"; do
    # export videos to their associated fold 
    grep -F -f "${output_prefix}_${fold}_paths.txt" "$keyfile" > "${output_prefix}/${fold}.txt"

    # "roll up" second-by-second observations that could be combined into one fragment
    mlr --nidx --fs " " --repifs put -q '
      begin {
        @obs = "";
        @start = 0;
        @stop = 1;
        @behavior = "";
      }
      if ($1 != @obs || $2 != @behavior || $3 != @stop) {
        if (NR > 1) {
          emit(@obs, @behavior, @start, @stop);
        }
        @obs = $1;
        @behavior = $2;
        @start = $3;
      }
      @stop = $4;
      $prev_observation = $1;
      $prev_behavior = $2;
      end {
        emit(@obs, @behavior, @start, @stop);
      }
    ' "${output_prefix}/${fold}.txt" > "${output_prefix}/${fold}_rolled.txt"

    # print out class frequencies of each fold
    echo "${2} ${fold} class freq"

    mlr --nidx --fs " " --repifs then put -S "
      @FPS = ${fps};
      \$3 = ceil(\$3 * @FPS);
      \$4 = floor(\$4 * @FPS);
      \$5 = \$4 - \$3;
    " then stats1 -a sum -f 5 -g 2 "${output_prefix}/${fold}_rolled.txt"

    # shuffle the training set
    if ${fold} == "training"; then
        cat "${output_prefix}/${fold}_rolled.txt" | shuf > "${output_prefix}/${fold}_shuf.txt"
    fi
done

rm "${output_prefix}_training_paths.txt" "${output_prefix}_testing_paths.txt" "${output_prefix}_evaluation_paths.txt"
cp "task${output_prefix}_class_to_int_mapping.txt" "${output_prefix}/class_to_int_mapping.txt"


### usage:

:'
tasks=("1" "2a" "2b" "2c" "3a" "3b" "4a" "4b" "5a" "5b" "6")

for task in "${tasks[@]}"; do
    bash splitter.sh "task${task}_split.txt" $task "task${task}_filelist_final.txt" 2
done
'