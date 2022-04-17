if !(pwd()*"/src" in LOAD_PATH) 
    push!(LOAD_PATH, pwd()*"/src")
    println("Pushed") 
else 
    println("Ready") 
end
using Cells

function main()
    s0 = insert_patterns(StateSquare(), [
        (PatternSquares.HWSS, (20,35)), 
        (PatternSquares.PentaDecathlon, (-2, 40)),
        (PatternSquares.Pulsar, (40, 10))
        ])
    
    history = iter_states(s0, 200)
    
    animate_square(history, "results/StateSquare/test.gif", 14)
end

@time main()