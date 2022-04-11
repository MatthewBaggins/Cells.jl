push!(LOAD_PATH, pwd()*"/src")
using Cells

function main()
    println("sss")
    s1 = State2DSquare(ones(3,3), Life)
    displayln(s1.grid)
    s2 = iter_state(s1)
    displayln(s2.grid)
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


