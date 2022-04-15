using Cells

function animate2D(history::Vector{Matrix{Bool}})
    anim = @animate for i=1:length(history)
        mat = history[i]
        heatmap(mat, clim=(0, 1))
    end
    gif(anim, "test2.gif", fps=10)
end

function main()
    s0 = insert_patterns(State2DSquare(), [
        (Cells.State.Patterns2D.Glider, (20,35)), 
        (Cells.State.Patterns2D.PentaDecathlon, (-2, 40)),
        (Cells.State.Patterns2D.Pulsar, (40, 10))
        ])
    
    history = Cells.State.State2D.iter_states(s0, 200)
    
    animate2D(history)
end

@time main()