# Based on this guide: https://ase.tufts.edu/chemistry/lin/images/FortranMD_TeachersGuide.pdf

using Atomistic
using NBodySimulator
using Plots
using Unitful
using UnitfulAtomic

N = 864
m = 6.6335209e-26u"kg"
box_size = 3.47786u"nm"
reference_temp = 94.4u"K"
average_v = √(u"k" * reference_temp / m)
thermostat_prob = 0.1 # this number was chosen arbitrarily
Δt = 1e-2u"ps"

potential_parameters = LJParameters(
	ϵ = 1.657e-21u"J",
	σ = 0.34u"nm",
	R = 0.765u"nm"
)

initial_bodies = MassBodies(N, m, average_v, box_size)
eq_parameters = NBSParameters(
	Δt=Δt,
	steps=2000,
	thermostat=AndersenThermostat(austrip(reference_temp), thermostat_prob / austrip(Δt))
)
eq_result = @time simulate(initial_bodies, eq_parameters, potential_parameters)

eq_stride = 10

temp = plot_temperature(eq_result, eq_stride)
energy = plot_energy(eq_result, eq_stride)

prod_parameters = NBSParameters(
	Δt=Δt,
	steps=5000,
	t₀=eq_parameters.steps * Δt
)
prod_result = @time simulate(get_bodies(eq_result), prod_parameters, potential_parameters)

prod_stride = 10

display(plot_temperature!(temp, prod_result, prod_stride))
display(plot_energy!(energy, prod_result, prod_stride))

rdf = @time plot_rdf(prod_result, potential_parameters.σ, 0.05)
display(rdf)
savefig(rdf, "artifacts/argon_lj_rdf.svg")

;
