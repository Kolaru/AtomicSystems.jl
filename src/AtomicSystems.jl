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
export atom_color, atom_mass, equivalent_systems

include("geometry.jl")
export center_of_mass

include("loading.jl")
export read, write

include("electronic_structure.jl")
export ElectronicTransition, Photoionization, AugerDecay, FluorescenceDecay
export ElectronicStructureBackend
export cross_section, rate, isa_photoionization, isa_auger_decay, isa_fluorescence, ejected_orbital
export calculate_photoionizations, calculate_auger_decays, calculate_fluorescence_decays,
    calculate_orbital_energies, calculate_decays
export highest_occupied_orbital, total_orbital_energy, binding_energy, closest_orbitals

end # module AtomicSystem
