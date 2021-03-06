module DifferencesBase

using SparseArrays

export AbstractDifference,
    VectorDifference,
    MatrixDifference,
    DictDifference,
    NamedTupleDifference,
    SetDifference,
    added_indices,
    modified_indices,
    removed_indices,
    added,
    common,
    modified,
    removed

include("types.jl")
include("differences.jl")
include("math.jl")
include("show.jl")

end # module
