### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ b8f5be54-ad2d-11eb-072a-9dd67f945eea
using Pkg; Pkg.activate("../Project.toml");

# ╔═╡ 823c8413-a7d1-4389-8ecc-1eb8e5c76419
using Photosynthesis, PlotPlants;

# ╔═╡ 50170e8b-113a-4bcd-8540-a77cb0d078b4
md"
# Photosynthesis: Photosynthetic rates

First of all, import the packages required. If you have not installed the package yet, do the following first:
```julia
using Pkg;
Pkg.add(\"Photosynthesis\");
Pkg.add(\"PlotPlants\");
```

Again, since we are using a separate project environment, what we need to do are (1) activate the environment, and (2) import the packages we need.
"

# ╔═╡ 99e1208e-fedc-488f-ae92-deeb38e7842d
md"
## Photosynthetic rates

Both C3 and C4 photosynthesis are colimited by three processes:
- Carboxylation (dark reaction; Ac)
- RubisCO regeneration (light reaction; Aj)
- Production (sugar metabolism; Ap)

The gross photosynthetic rate (Ag) ought to be the minimum of the three:
```math
A_\text{g} = \text{min} \left( A_\text{c},\ A_\text{j},\ A_\text{p} \right) .
```
The net photosynthetic rate (An) is Ag minus the respiration rate (Rd)
```math
A_\text{n} = A_\text{g} - R_\text{d} .
```

### C3 photosynthesis

For C3 photosynthesis, the carboxylation limited rate is
```math
A_\text{c} = V_\text{cmax} \cdot \dfrac{P_\text{i} - \Gamma^{*}}{P_\text{i} + K_\text{M}} ,
```
where ``V_\text{cmax}`` is maximum carboxylation rate at leaf temperature, ``P_\text{i}`` is the CO₂ partial pressure, ``\Gamma^{*}`` is the CO₂ compensation point, and ``K_\text{M}`` is the Michaelis-Menten coefficient. ``K_\text{M}`` is computed using
```math
K_\text{M} = K_\text{C} \cdot \left( 1 + \dfrac{P_{\text{O}_2}}{K_\text{O}} \right)
```
where ``K_\text{C}`` is the RubisCO coefficient for CO₂ at leaf temperature, ``P_{\text{O}_2}`` is the O₂ partial pressure, and ``K_\text{O}`` is the RubisCO cofficient for O₂ at leaf temperature.

---
The RubisCO regenration limited rate is
```math
A_\text{j} = J \cdot \dfrac{P_\text{i} - \Gamma^{*}}{a \cdot P_\text{i} + b \cdot \Gamma^{*}}
```
where ``J`` is the electron transport rate, and a and b are constants depending on NADPH/ATP stochiometry. Typically a = 4, and b = 8. ``J`` is computed using
```math
J = \text{max} \left( J_\text{max},\ f_\text{PSII} \cdot \text{PSII}_\text{max} \cdot \text{APAR} \right).
```
where ``J_\text{max}`` is maximum electron transport rate at leaf temperature, ``f_\text{PSII}`` is fraction of electron that goes to photosystem II, ``\text{PSII}_\text{max}`` is maximum photosystem II yield, and APAR is the absorbed photosynthetically active radition.

---
The prodcut limited rate is
```math
A_\text{p} = \dfrac{V_\text{cmax}}{2} .
```

Note that most of the parameters used are temperature dependent, such as ``V_\text{cmax}``, ``K_\text{M}``, and ``J_\text{max}``. Thus, temperature correction is needed before computing the photosynthetic rates. As a result, steps for computing gross or net photosynthetic rates are
- Make temperature correction
- Calaulate electron transport rate from APAR
- Calculate Ac
- calculate Aj
- Calculate Ap
- Calculate Ag and An

To make it easier for users, these functions are nested in one function: `leaf_photosynthesis!`. Down below, we use some toy examples to show how to use Photosynthesis.jl.

#### Impact of CO₂ partial pressure
"

# ╔═╡ 05ea562c-9d12-43f3-82d9-505465bf8076
# create some structures to work on
begin
	leaf = Leaf{Float32}(APAR = 1000);
	psm = C3CLM(Float32);
	envir = AirLayer{Float32}();
end;

# ╔═╡ 09bb6afd-20f8-4416-99df-74fd7f62819c
# step CO₂ from 5 to 120 Pa
begin
	leaf.T = Float32(298.15);
	p_CO₂_s = collect(Float32, 5:1:120);
	a_c_s = similar(p_CO₂_s); a_j_s = similar(p_CO₂_s); a_p_s = similar(p_CO₂_s);
	a_g_s = similar(p_CO₂_s); a_n_s = similar(p_CO₂_s);
	for _i in eachindex(p_CO₂_s)
		leaf_photosynthesis!(psm, leaf, envir, PCO₂Mode(), p_CO₂_s[_i]);
		a_c_s[_i] = leaf.Ac; a_j_s[_i] = leaf.Aj; a_p_s[_i] = leaf.Ap;
		a_g_s[_i] = leaf.Ag; a_n_s[_i] = leaf.An;
	end;
end;

# ╔═╡ fbb66cd6-6163-441d-a4c9-3769ef42ab8f
begin
	# plot the results
	fig1,axs1 = create_canvas("vs CO₂");
	ax1 = axs1[1];
    fig1.patch.set_facecolor("gray");
    ax1.set_facecolor("gray");
	ax1.plot(p_CO₂_s, a_c_s, "k:", label="Ac");
	ax1.plot(p_CO₂_s, a_j_s, "k--", label="Aj");
	ax1.plot(p_CO₂_s, a_p_s, "k-", label="Ap");
	ax1.plot(p_CO₂_s, a_g_s, "c-", alpha=0.5, label="Ag");
	ax1.plot(p_CO₂_s, a_n_s, "r-", alpha=0.5, label="An");
	ax1.legend(loc="lower right", facecolor="none", edgecolor="none", ncol=2);
	set_xylabels!(axs1, "CO₂ partial pressure (Pa)", "Photosynthetic rate (μmol m⁻² s⁻¹)", fontsize=12);
	fig1
end

# ╔═╡ 9eac2f87-f132-4cb7-9280-3b8a3600e6bb
md"
#### Impact of APAR
"

# ╔═╡ 83ca66d1-ac84-4a3b-8903-658279dfb5a0
# step APAR from 0 to 2000 Pa
begin
	leaf.T = Float32(298.15);
	apar_s = collect(Float32, 0:10:2000);
	b_c_s = similar(apar_s); b_j_s = similar(apar_s); b_p_s = similar(apar_s);
	b_g_s = similar(apar_s); b_n_s = similar(apar_s);
	for _i in eachindex(apar_s)
		leaf.APAR = apar_s[_i];
		leaf_photosynthesis!(psm, leaf, envir, PCO₂Mode(), Float32(30));
		b_c_s[_i] = leaf.Ac; b_j_s[_i] = leaf.Aj; b_p_s[_i] = leaf.Ap;
		b_g_s[_i] = leaf.Ag; b_n_s[_i] = leaf.An;
	end;
end;

# ╔═╡ 1c190294-bace-4563-b771-f4bb78892262
begin
	# plot the results
	fig2,axs2 = create_canvas("vs APAR");
	ax2 = axs2[1];
    fig2.patch.set_facecolor("gray");
    ax2.set_facecolor("gray");
	ax2.plot(apar_s, b_c_s, "k:", label="Ac");
	ax2.plot(apar_s, b_j_s, "k--", label="Aj");
	ax2.plot(apar_s, b_p_s, "k-", label="Ap");
	ax2.plot(apar_s, b_g_s, "c-", alpha=0.5, label="Ag");
	ax2.plot(apar_s, b_n_s, "r-", alpha=0.5, label="An");
	ax2.legend(loc="lower right", facecolor="none", edgecolor="none", ncol=2);
	set_xylabels!(axs2, "APAR (μmol m⁻² s⁻¹)", "Photosynthetic rate (μmol m⁻² s⁻¹)", fontsize=12);
	fig2
end

# ╔═╡ 8718ac6f-0ea2-4303-abb6-cf1472b898f8
md"
#### Impact of temperature
"

# ╔═╡ 844409d7-b553-4316-8405-8c85884767dd
# step temperature from 0 to 40 °C
begin
	leaf.APAR = 1000;
	T_s = collect(Float32, 0:1:40);
	c_c_s = similar(T_s); c_j_s = similar(T_s); c_p_s = similar(T_s);
	c_g_s = similar(T_s); c_n_s = similar(T_s);
	for _i in eachindex(T_s)
		leaf.T = T_s[_i] + Float32(273.15);
		leaf_photosynthesis!(psm, leaf, envir, PCO₂Mode(), Float32(30));
		c_c_s[_i] = leaf.Ac; c_j_s[_i] = leaf.Aj; c_p_s[_i] = leaf.Ap;
		c_g_s[_i] = leaf.Ag; c_n_s[_i] = leaf.An;
	end;
end;

# ╔═╡ 707749b7-0fa7-4a12-8daf-2eb03f899185
begin
	# plot the results
	fig3,axs3 = create_canvas("vs T");
	ax3 = axs3[1];
    fig3.patch.set_facecolor("gray");
    ax3.set_facecolor("gray");
	ax3.plot(T_s, c_c_s, "k:", label="Ac");
	ax3.plot(T_s, c_j_s, "k--", label="Aj");
	ax3.plot(T_s, c_p_s, "k-", label="Ap");
	ax3.plot(T_s, c_g_s, "c-", alpha=0.5, label="Ag");
	ax3.plot(T_s, c_n_s, "r-", alpha=0.5, label="An");
	ax3.legend(loc="upper left", facecolor="none", edgecolor="none", ncol=2);
	set_xylabels!(axs3, "T (°C)", "Photosynthetic rate (μmol m⁻² s⁻¹)", fontsize=12);
	fig3
end

# ╔═╡ Cell order:
# ╟─50170e8b-113a-4bcd-8540-a77cb0d078b4
# ╠═b8f5be54-ad2d-11eb-072a-9dd67f945eea
# ╠═823c8413-a7d1-4389-8ecc-1eb8e5c76419
# ╟─99e1208e-fedc-488f-ae92-deeb38e7842d
# ╠═05ea562c-9d12-43f3-82d9-505465bf8076
# ╠═09bb6afd-20f8-4416-99df-74fd7f62819c
# ╠═fbb66cd6-6163-441d-a4c9-3769ef42ab8f
# ╟─9eac2f87-f132-4cb7-9280-3b8a3600e6bb
# ╠═83ca66d1-ac84-4a3b-8903-658279dfb5a0
# ╠═1c190294-bace-4563-b771-f4bb78892262
# ╟─8718ac6f-0ea2-4303-abb6-cf1472b898f8
# ╠═844409d7-b553-4316-8405-8c85884767dd
# ╠═707749b7-0fa7-4a12-8daf-2eb03f899185
