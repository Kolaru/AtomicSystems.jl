module AtomicSystems

using PeriodicTable
using Unitful, UnitfulAtomic

include("atomic_system.jl")
export Atom, AtomicSystem
export iselement, to_element, atom_colors, atom_masses, equivalent_systems

include("loading.jl")

# Generic functions
export atomic_color, atomic_mass, element_symbol

atomic_mass(generic) = to_element(generic).atomic_mass
atomic_color(generic) = to_element(generic).cpk_hex
element_symbol(generic) = Symbol(to_element(generic).symbol)

end # module AtomicSystem
