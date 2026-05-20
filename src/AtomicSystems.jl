module AtomicSystems

using AtomicLevels
using PeriodicTable
using Printf
using Statistics
using Unitful, UnitfulAtomic

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
export calculate_photoionizations, calculate_decays, calculate_orbital_energies
export highest_occupied_orbital, total_orbital_energy, binding_energy, closest_orbital_in_energy

end # module AtomicSystem
