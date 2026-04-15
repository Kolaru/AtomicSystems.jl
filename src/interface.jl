abstract type ElectronicTransition end

struct Photoionization <: ElectronicTransition
    atom::Element
    cross_section::Float64
    emitted_electron_energy::Float64
    initial_configuration::Configuration
    final_configuration::Configuration
end

cross_section(ph::Photoionization) = ph.cross_section

struct AugerDecay <: ElectronicTransition
    atom::Element
    rate::Float64
    emitted_electron_energy::Float64
    initial_configuration::Configuration
    final_configuration::Configuration
end

struct FluorescenceDecay <: ElectronicTransition
    atom::Element
    rate::Float64
    emitted_photon_energy::Float64
    initial_configuration::Configuration
    final_configuration::Configuration
end

rate(decay::Union{AugerDecay, FluorescenceDecay}) = decay.rate

isa_photoionization(event::ElectronicTransition) = false
isa_photoionization(event::Photoionization) = true

isa_auger_decay(event::ElectronicTransition) = false
isa_auger_decay(event::AugerDecay) = true

isa_fluoresence(event::ElectronicTransition) = false
isa_fluoresence(event::FluorescenceDecay) = true

"""
    abstract type ElectronicStructureBackend end

Super type for the backend computing the electronic structures required by the problem.
"""
abstract type ElectronicStructureBackend end

"""
    calculate_photoionizations(xatom::ElectronicStructureBackend, photon_energy::Quantity, atom::Element [, configuration::Configuration])

Use the given backend to calculate the possible electronic transition for an atom in a given configuration.

Return a list of `Photoionization`.
"""
function calculate_photoionizations end

"""
    calculate_decays(backend::ElectronicStructureBackend, atom::Element [, configuration::Configuration])

Use the given backend to calculate the possible electronic transition for an atom in a given configuration.

Return a list of `ElectronicTransition`.
"""
function calculate_decays end

"""
    calculate_orbital_energies(backend::ElectronicStructureBackend, atom::Element [, configuration::Configuration])

Use the given backend to calculate the the orbital energies of an atom in a given configuration.

Return a list of energies in atomic units, in the same order as the orbitals in `configuration`.
"""
function calculate_orbital_energies end
