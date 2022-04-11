using Cells
using Plots

function animate2D(history::Vector{Matrix{Bool}})
    anim = @animate for i=1:length(history)
        mat = history[i]
        heatmap(mat, clim=(0, 1))
    end
    gif(anim, "test.gif", fps=10)
end

function main()
    s = State2DSquare()
    s0 = insert_patterns(
        s, [(Cells.State.Patterns2D.Glider, (-2,-2)), 
            (Cells.State.Patterns2D.PentaDecathlon, (-2, 40)),
            (Cells.State.Patterns2D.Pulsar, (40, 10))])
    # displayln(s0.grid)
    history = Cells.State.State2D.iter_states(s0, 200)
    # for (i, h) in enumerate(history)
    #     println(i)
    #     displayln(h)
    # end
    animate2D(history)
end

@time main()


# function main()
#     grid = zeros(3, 3)
#     state = State2DSquare(grid, Life)
#     state1 = insert_patterns(state, [
#         (Glider, (-1, -1)), 
#         (Blinker, (3, 10)),
#         (MWSS, (-10, -13)),
#         (Block, (-20, -20))
#         ])

#     println(state1.origin)
#     state2 = iter_state(state1, 24)
#     displayln(state2.grid)
#     println(state2.origin)
#     displayln(state)
#     o_display(state2, -20:-19, -20:-19)
# end


