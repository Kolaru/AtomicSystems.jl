module AtomicSystems

using AtomicLevels
using Memoization
using PeriodicTable
using Printf
using Statistics
using TaskLocalValues
using ThreadSafeDicts
using Unitful, UnitfulAtomic

include("task_local_dict.jl")
export TaskLocalDict

include("atomic_system.jl")
export Atom, AtomicSystem
export iselement, to_element, to_element_symbol
export atom_color, atomic_mass, atom_mass, atom_symbol, equivalent_systems

include("geometry.jl")
export center_of_mass

include("loading.jl")
export read, write

include("electronic_structure.jl")
export ElectronicTransition, Photoionization, AugerDecay, FluorescenceDecay
export ElectronicStructureBackend
export cross_section, rate, isa_photoionization, isa_auger_decay, isa_fluorescence, ejected_orbital
export calculate_photoionizations, calculate_auger_decays, calculate_fluorescence_decays,
    calculate_orbital_energies, calculate_total_energy
export calculate_decays, highest_occupied_orbital, total_orbital_energy, binding_energy, closest_orbitals

# Generic functions
export atomic_color, atomic_mass, element_symbol

atomic_mass(generic) = to_element(generic).atomic_mass
atomic_color(generic) = to_element(generic).cpk_hex
element_symbol(generic) = Symbol(to_element(generic).symbol)

end # module AtomicSystem
