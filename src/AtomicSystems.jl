module AtomicSystems

using AtomicLevels
using PeriodicTable
using Unitful, UnitfulAtomic

include("atomic_system.jl")
export Atom, AtomicSystem
export iselement, to_element, atom_colors, atom_masses, equivalent_systems

include("loading.jl")

include("interface.jl")
export ElectronicTransition, Photoionization, AugerDecay, FluorescenceDecay
export ElectronicStructureBackend
export cross_section, rate, isa_photoionization, isa_auger_decay, isa_fluoresence
export calculate_photoionizations, calculate_decays, calculate_orbital_energies

end # module AtomicSystem
