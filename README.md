# AtomicSystem.jl

This package is a small utility to handle system of atoms,
bundling together the atom information and their index in the system.

An `AtomicSystem` is created either from a list of elements,
a list of names, or both:

```julia
julia> AtomicSystem([:C, :O, :O])
Atomic system with 3 atoms
  C (Carbon)
  O1 (Oxygen)
  O2 (Oxygen)

julia> AtomicSystem(["C", "O2", "O1"])
Atomic system with 3 atoms
  C (Carbon)
  O2 (Oxygen)
  O1 (Oxygen)

julia> AtomicSystem(["Crow", "Oriole", "Odoacare"], [:C, :O, :O])
Atomic system with 3 atoms
  Crow (Carbon)
  Oriole (Oxygen)
  Odoacare (Oxygen)
```

When only the names are given, they must have the form `<atom_symbol><number>`,
so that their element can be parsed.

An `AtomicSystem` is iterable and support various indexing:
```julia
julia> system = AtomicSystem([:C, :O, :O])
Atomic system with 3 atoms
  C (Carbon)
  O1 (Oxygen)
  O2 (Oxygen)

# Indexing by position
julia> system[2]
O1 - Oxygen atom with index 2

# Indexing by atom name
julia> system["O2"]
O2 - Oxygen atom with index 3

# Retrieving all atom of a given element (using PeriodicTable.Element)
julia> system[elements[:O]]
2-element Vector{Atom}:
 O1 - Oxygen atom with index 2
 O2 - Oxygen atom with index 3
```

The `Atom` object have the fields `name`, `element` (a `PeriodicTable.Element`),
and `index` (the index of the atom in the original system).

Conveniently, an `Atom` can be used to index *any* array:
```julia
julia> colors = [:black, :white, :white]
3-element Vector{Symbol}:
 :black
 :white
 :white

julia> colors[system["C"]]
:black

julia> positions = rand(3, 3)
3×3 Matrix{Float64}:
 0.530395  0.894371  0.405726
 0.051145  0.420538  0.712605
 0.543706  0.748318  0.579439

julia> positions[:, system["O2"]]
3-element Vector{Float64}:
 0.4057258254271655
 0.7126053584082694
 0.5794390016772784
```