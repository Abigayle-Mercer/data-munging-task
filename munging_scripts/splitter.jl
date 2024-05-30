susing Distances, DataFrames, CSV, DataStructures, Random

###### PARAMETERS -- ONLY CHANGE THESE ######
label_src = "/mnt/durable/training_data/phase2/task3b_filelist_final.txt"
group_symbols = [:Observation, :label]

print(label_src)

n_iters = 100
n_best = 10

#######

exclude_vids = [] 

df = combine(
        groupby(
            transform!(
                    DataFrame(CSV.File(label_src, header=[:Observation, :label, :start, :stop], delim=" ")),
                [:stop, :start] => ((stop, start) -> stop - start) => :duration
            ),
            group_symbols, 
        ),
        :duration => sum => :summed_durations)

videos = unique(df[:, group_symbols[1]])
labels = unique(df[:, group_symbols[2]])

print(labels)

M = zeros((length(videos), length(labels)))

for row in eachrow(df)
    M[findfirst(==(row[group_symbols[1]]), videos), findfirst(==(row[group_symbols[2]]), labels)] = row.summed_durations
end

colsum = sum(M; dims=1)

chi_take = collect(1:length(labels))
for (cdx, (lbl, cs)) in enumerate(zip(labels, colsum))
    if count(>(0), M[:, cdx]) <= 2
        println("Warning: two or fewer videos contain label $lbl. Ignoring it")
        deleteat!(chi_take, findfirst(==(cdx), chi_take))
    end
end

avg = colsum / length(videos)

function m_folds(M)
    take = Tuple(shuffle(collect(1:length(videos))))
    take = collect(take)

    efold = sort(take[1:n_test])
    tfold = sort(take[n_test+1:2*n_test+1])
    train = sort(take[2*n_test + 2:end])

    eM = sum(M[efold, :]; dims=1)
    tM = sum(M[tfold, :]; dims=1)
    trainM = sum(M[train, :]; dims=1)

    efold, tfold, train, eM, tM, trainM
end

pqueue = PriorityQueue()
n_test = Int(ceil(length(videos) / 10))
n_train = length(videos) - 2*n_test

for i in 1:n_iters
    efold, tfold, train, eM, tM, trainM = m_folds(M)

    d = maximum([
        chisq_dist(eM[chi_take], (avg * n_test)[chi_take]),
        chisq_dist(tM[chi_take], (avg * n_test)[chi_take]),
        chisq_dist(trainM[chi_take], (avg * n_train)[chi_take]),
    ])
    enqueue!(pqueue, (efold, tfold, train),  -d)

    if length(pqueue) > n_best
        dequeue!(pqueue)
    end
end

while length(pqueue) > 0
    efold, tfold, train = dequeue!(pqueue)
    efold, tfold, train, eM, tM, trainM = m_folds(M)
    
    println("Training: ", sort([videos[x] for x in train]))
    println("Testing: ", sort([videos[x] for x in tfold]))
    println("Evaluation: ", sort([videos[x] for x in efold]))

    println(DataFrame(hcat(["Training", "Testing", "Evaluation"], [trainM; tM; eM]), vcat(["Fold"], string.(labels))))
end