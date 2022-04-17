using Plots

function animate_square(history::Vector{T} where {T <: AbstractMatrix{Bool}}, path::String, fps::Integer=10)
    @assert 0 < fps
    if path[end-3 : end] != ".gif"
        path *= ".gif"
    end
    println(path)
    anim = @animate for i=1:length(history)
        mat = history[i]
        heatmap(mat, clim=(0, 1))
    end
    gif(anim, path, fps=fps)
end

