### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ c5edefaa-c7e5-429c-a43a-dbc8a5701a4d
using Pkg; Pkg.activate("../Project.toml");

# ╔═╡ 04df1fd2-a7bd-11eb-09da-2b1fe050be70
using Photosynthesis, PlotPlants

# ╔═╡ b31090fd-6def-4a95-87e7-c6e04069bf55
md"
# Photosynthesis: Parameter Sets

First of all, import the packages required. If you have not installed the package yet, do the following first:
```julia
using Pkg;
Pkg.add(\"Photosynthesis\");
Pkg.add(\"PlotPlants\");
```

Now we are using a separate project environment, so what we need to do are (1) activate the environment, and (2) import the packages we need.
"

# ╔═╡ 76502093-e9c5-4859-82bc-71582b2f28d2
md"
There are many pre-defined parameter sets in Photosynthesis.jl, but in this tutorial I will simply go over some convenient setups. For more customized parameter sets, please read the detailed documentations online. Anyway, I will try my best to include as much as possible in this tutorial.

Photosynthesis.jl is a highly modularized module, and as a result many information needs to and has been classified to groups of structures. For example, when we want to compute leaf photosynthetic rate, we may store the information as individual floats, and pass the floats into functions to compute the photosynthetic rate. Sure this method works, but is it the best way to do it or to use? The answer is no. A better way ought to be to classify the information as a few structures, and then operate on the structure directly. Yes, we may use more memory to store redundent information, but it is much easier to repeat this progress. Further, we may use the multiple dispatch feature of Julia to do different things when we pass different parameters to the same function. Down below I will show you the design of Photosynthesis.jl.

## Leaf

Most of the the information required to run leaf-level photosynthesis is stored in the Leaf structure. Note that the photosynthesis model parameters like temperature dependency functions are not part of the Leaf structure. A tip, when using Pluto notebook, you may read the live docs for more information about functions and structures. Now let's create tow leaves, note that you need to declar which float type you want to use: Float32 or Float64.
"

# ╔═╡ f864d5a7-f30e-4da0-8eb0-0054762cac29
begin
    leaf_3 = Leaf{Float32}();
    leaf_4 = Leaf{Float64}();
end;

# ╔═╡ ddddb377-44ba-4ac4-9243-75705a0dfba0
md"
Yep, that is all we need to do, and that is to define a container to store the photosynthesis-related information. When we need to read some value out, just read from the Leaf structure. For example, the maximum carboxylation rate and Machaelis coefficient:
"

# ╔═╡ b94760bc-d1b4-4897-a848-d8002db6548b
leaf_3.Vcmax25

# ╔═╡ 1c8559cb-1c14-4745-80a2-97e14fc27670
leaf_3.Km

# ╔═╡ b7b97a18-bf84-49ef-a157-24ebf6e4b982
md"
You will find that the Michaelis coefficient is 0, meaning that the leaf structure is not yet initialized. Thus, when using Photosynthesis.jl, make sure thing are initialized. Several environmental or physiological parameters may impact the initialization, such as leaf temperature, atmospheric oxygen concentration, and absorbed photosynthetically active radiation. In most cases, users do not need to worry about the parameter initialization as the Photosynthesis.jl handles that, such as when leaf temperature changes or when radiation changes. However, to make the code more efficient, some redundant calculations are often done only at the very beginning, and thus users need to make sure the parameters are updated when trying out this package.

Next, we will talk about the environmental conditions: a layer of air surrounding the leaf.

## AirLayer

The AirLayer structure stores all the air information that may impact photosynthesis including those that impact stomatal opening, such as atmospheric CO₂ partial pressure and air relative humidity. Like what we did for Leaf, define an AirLayer structure is pretty simple.
"

# ╔═╡ 8bad06bd-deda-4730-88e9-f24e81298776
begin
    air_3 = AirLayer{Float32}();
    air_4 = AirLayer{Float64}();
end;

# ╔═╡ df33c06c-81cf-45c2-a1e5-a1ac88100344
md"
Now let's try to see some key environmental conditions (you may try more by yourself). Note that the unit used here are basically SI, some exceptions are the photosynthetic rate and capacity. And yes, always be cautious about the unit!
"

# ╔═╡ c92d2410-78bb-4302-9cdc-f0bc239c7cda
air_3.vpd

# ╔═╡ 5990d82c-b167-426d-84f1-bc8d7b0f954e
air_4.p_H₂O

# ╔═╡ 97c87f73-1a7f-466e-b339-44b452a75bc7
air_3.p_O₂

# ╔═╡ 7d3799c6-fa1a-44df-88ff-a16cae6cea61
air_4.p_atm

# ╔═╡ 4a76ae80-62cb-4f14-b8b0-38855e9f7da1
md"
Next, let us see the pre-defined temperature dependency parameter sets.

## Temperature dependency

There are three commonly used temperature dependency function, and they are
- Arrhenius
- Arrhenius with a peak
- Q10

The three functions differ in their formulations. The Arrhenius formation reads
```math
\text{correction} = \exp \left( \dfrac{ΔHa}{RT_0} - \dfrac{ΔHa}{RT_1} \right)
```

The peaked Arrhenius formation has an extra deactivation term at high temperature:
```math
\text{correction} = \exp \left( \dfrac{ΔHa}{RT_0} - \dfrac{ΔHa}{RT_1} \right) \cdot \dfrac{1+\exp \left(\dfrac{S_\text{v}T_0-H_\text{d}}{RT_0}\right)}{1+\exp \left(\dfrac{S_\text{v}T_0-H_\text{d}}{RT_1}\right)}
```

The Q10 formation reads:
```math
\text{correction} = \left( \dfrac{T_1 - T_0}{10} \right)^{Q_{10}}
```

Users may define their own temperature dependency structure following the documentation for each stcuture field. Here I will not go over the details. I will simply list a toy example for Q10 dependency (because it is easiest). Here it means that the reference value at 15 °C (288.15 K) is 1, and the Q10 exponent is 1.2:
"

# ╔═╡ 8e50a246-248f-4a36-b13e-16db9bf42184
q10_td = Q10TD{Float32}(1, 288.15, 1.2);

# ╔═╡ 37eccf99-8551-49cd-a520-ccc8cc936b0c
md"
Let us now try to visualize the difference of the three. We may use some pre-defined parameter sets for this.
"

# ╔═╡ 5ce95d97-4f2d-44b4-8359-f693c1accc58
begin
    _ts = collect(Float64, 273:1:323);
    _td_arrh = KcTDCLM(Float64);
    _td_peak = VcmaxTDCLM(Float64);
    _td_q10  = Q10TD{Float64}(1.0, 298.15, 1.7);
    _ks_arrh = temperature_correction.([_td_arrh], _ts);
    _ks_peak = temperature_correction.([_td_peak], _ts);
    _ks_q10  = temperature_correction.([_td_q10 ], _ts);

    _fig,_axes = create_canvas(1);
    _ax1 = _axes[1];
    _fig.patch.set_facecolor("gray");
    _ax1.set_facecolor("gray");
    _ax1.plot(_ts .- 273.15, _ks_arrh, "k-");
    _ax1.plot(_ts .- 273.15, _ks_peak, "k--");
    _ax1.plot(_ts .- 273.15, _ks_q10 , "k:");
    _ax1.set_xlabel("Leaf temperature (°C)");
    _ax1.set_ylabel("Relative to 25 °C");
    _fig
end

# ╔═╡ 4df07426-8509-49df-962e-53d38a56df52
md"
For more details about the pre-defined temperature dependency parameter sets, please visit the online [documentation](https://yujie-w.github.io/Photosynthesis.jl/dev/API/#Temperature-Dependency-Structs).

Here, I simply listed two examples. Users do not need to memorize this as we will have much more convenient setups.
"

# ╔═╡ 94684c5c-523e-4257-9cf4-c907179662a9
begin
    _td_1 = JmaxTDBernacchi(Float32);
    _td_2 = VcmaxTDCLM(Float32);
end;

# ╔═╡ 874639a4-a2de-4c2e-9bb2-2c88ad51e204
md"
Is this easy enough? Yes and no. One might want to ask, there are quite a few temperature dependency we need to simulate photosynthesis, and we may need different parameter sets for C₃ anc C₄ photosynthesis. How to do with those?

Well, for now we will go over the key part of the Photosynthesis.jl package: computing photosynthetic rates. As I mentioned above, we do not have photosynthesis type stored in the Leaf structure, and thus we need to tell the function which type of photosynthesis we want to simulate and what kinds of temperature dependency we want to use. This is done via the multiple dispatch feature, and to use this we need to define two different types of structure:
- C3ParaSet
- C4ParaSet

For example, we may create a C3ParaSet and C4ParaSet using default CLM parameter setups (note here C3CLM and C4CLM are functions to initialize structures). Yet, you may choose to customize the combination of temperature dependencies, but you will need to read the documentaions.
"

# ╔═╡ e09b29cb-b5af-44e1-8e63-ac0a6f381a17
begin
    c3_model = C3CLM(Float32);
    c4_model = C4CLM(Float64);
end;

# ╔═╡ 502784e9-fc43-445f-8f8c-cc3c3aa52cbc
md"
Photosynthesis.jl support the computation of photosynthetic rates based on either the leaf internal CO₂ partial pressure (PCO₂Mode) or the stomatal conductance (GCO₂Mode), we need to tell the function which mode we choose:

Yes, this is now the last step. Now let us calculate the C₃ and C₄ photosynthesis!
"

# ╔═╡ 90cfc73a-3bae-4d0c-a2d2-f9052bf15c0a
begin
    leaf_photosynthesis!(c3_model, leaf_3, air_3, PCO₂Mode(), Float32(20));
    leaf_3.An
end

# ╔═╡ 881ec773-5cf3-45c7-9f99-636047b2a561
begin
    leaf_photosynthesis!(c3_model, leaf_3, air_3, GCO₂Mode(), Float32(0.1));
    leaf_3.An
end

# ╔═╡ dc8a1252-e6ed-4190-a18e-97d2eba54c53
begin
    leaf_photosynthesis!(c4_model, leaf_4, air_4, PCO₂Mode(), Float64(20));
    leaf_4.An
end

# ╔═╡ e6870e21-2082-4201-b1d4-21637002266a
begin
    leaf_photosynthesis!(c4_model, leaf_4, air_4, GCO₂Mode(), Float64(0.1));
    leaf_4.An
end

# ╔═╡ 054a2d9e-23f1-4e7f-a3c3-69bbac92c37f
md"
Is it pretty easy? We will go over the details of Photosynthesis.jl in the next tutorial.
"

# ╔═╡ Cell order:
# ╟─b31090fd-6def-4a95-87e7-c6e04069bf55
# ╠═c5edefaa-c7e5-429c-a43a-dbc8a5701a4d
# ╠═04df1fd2-a7bd-11eb-09da-2b1fe050be70
# ╟─76502093-e9c5-4859-82bc-71582b2f28d2
# ╠═f864d5a7-f30e-4da0-8eb0-0054762cac29
# ╟─ddddb377-44ba-4ac4-9243-75705a0dfba0
# ╠═b94760bc-d1b4-4897-a848-d8002db6548b
# ╠═1c8559cb-1c14-4745-80a2-97e14fc27670
# ╟─b7b97a18-bf84-49ef-a157-24ebf6e4b982
# ╠═8bad06bd-deda-4730-88e9-f24e81298776
# ╟─df33c06c-81cf-45c2-a1e5-a1ac88100344
# ╠═c92d2410-78bb-4302-9cdc-f0bc239c7cda
# ╠═5990d82c-b167-426d-84f1-bc8d7b0f954e
# ╠═97c87f73-1a7f-466e-b339-44b452a75bc7
# ╠═7d3799c6-fa1a-44df-88ff-a16cae6cea61
# ╟─4a76ae80-62cb-4f14-b8b0-38855e9f7da1
# ╠═8e50a246-248f-4a36-b13e-16db9bf42184
# ╟─37eccf99-8551-49cd-a520-ccc8cc936b0c
# ╠═5ce95d97-4f2d-44b4-8359-f693c1accc58
# ╟─4df07426-8509-49df-962e-53d38a56df52
# ╠═94684c5c-523e-4257-9cf4-c907179662a9
# ╟─874639a4-a2de-4c2e-9bb2-2c88ad51e204
# ╠═e09b29cb-b5af-44e1-8e63-ac0a6f381a17
# ╟─502784e9-fc43-445f-8f8c-cc3c3aa52cbc
# ╠═90cfc73a-3bae-4d0c-a2d2-f9052bf15c0a
# ╠═881ec773-5cf3-45c7-9f99-636047b2a561
# ╠═dc8a1252-e6ed-4190-a18e-97d2eba54c53
# ╠═e6870e21-2082-4201-b1d4-21637002266a
# ╟─054a2d9e-23f1-4e7f-a3c3-69bbac92c37f
