using Cells
using Images
using ProgressBars

function main()
    for rule::UInt8 in ProgressBar(0:255)
        s = StateECA(rule)
        history = iter_states(s, 128)
        save("results/ECA/Rule $rule.png", history)
    end
end

@time main()