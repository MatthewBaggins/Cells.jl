using Cells
using Images
using ProgressBars

function main()
    for rule::UInt8 in ProgressBar(0:255)
        s = State1DWolfram(rule)
        history = iter_states(s, 128)
        save("wolfram_rule_$rule.png", history)
    end
end

@time main()