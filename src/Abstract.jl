module Abstract

# Rule
export AbstractRule2D

abstract type AbstractRule end

abstract type AbstractRule2D <: AbstractRule end

# State
export AbstractState1D, AbstractState2D

abstract type AbstractState end

abstract type AbstractState1D <: AbstractState end

abstract type AbstractState2D <: AbstractState end

end