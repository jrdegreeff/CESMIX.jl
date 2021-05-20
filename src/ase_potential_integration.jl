struct ASEForceGenerationParameters <: ForceGenerationParameters
    box_size::Quantity
    element::ElementCoulomb
    lattice::AbstractArray{Quantity, 2}
    parameters::ASEPotential.ASECalculatorParameters
end

function generate_forces(bodies::Vector{MassBody}, parameters::ASEForceGenerationParameters)
    dftk_atoms = [parameters.element => [auconvert.(u"bohr", b.r) / parameters.box_size for b ∈ bodies]]
    atoms = ase_atoms(austrip.(parameters.lattice), dftk_atoms)
    forces = @time get_forces(atoms, parameters.parameters)
    return ParticleForcePotentialParameters(forces)
end
