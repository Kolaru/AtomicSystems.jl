module AtomicSystems

using PeriodicTable
using Unitful, UnitfulAtomic

include("atomic_system.jl")
export Atom, AtomicSystem
export iselement, to_element, to_element_symbol, atom_colors, atom_masses, equivalent_systems

include("loading.jl")

end # module AtomicSystem
