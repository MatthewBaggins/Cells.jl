module Abstract

# Rule
export AbstractRule

abstract type AbstractRule end

# State
export AbstractState, AbstractState1D, AbstractState2D

abstract type AbstractState end

abstract type AbstractState1D <: AbstractState end

abstract type AbstractState2D <: AbstractState end

end