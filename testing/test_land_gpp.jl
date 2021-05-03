### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 43661f9d-f832-4519-a85f-e1545b873cf2
using Pkg; Pkg.activate("../Project.toml");

# ╔═╡ f83782f0-a2e2-11eb-0fec-d109f41f496b
using PkgUtility,PyPlot

# ╔═╡ 91967790-2c00-4289-a1d1-239f898442fa
begin
    data_b = read_nc("/home/wyujie/Data/LandGPP/nc/B_2020_1X.nc", "weibullb");
    data_k = read_nc("/home/wyujie/Data/LandGPP/nc/K_2020_1X.nc", "kmax");
    data_e = read_nc("/home/wyujie/Data/LandGPP/nc/RMSE_2020_1X.nc", "rmse");
end;

# ╔═╡ f1272e55-93c4-43f2-b953-3e2a1c463d3d
begin
    figure(1, figsize=(10,5), dpi=100);
    clf();
    map_b = imshow(data_b', origin="lower", vmin=0, vmax=4);
    colorbar(map_b);
    gcf()
end

# ╔═╡ b69b3d5c-79b2-4456-95e0-74fe5a8eb49b
begin
    figure(2, figsize=(10,5), dpi=100);
    clf();
    map_k = imshow(data_k', origin="lower", vmin=0, vmax=4);
    colorbar(map_k);
    gcf()
end

# ╔═╡ bff2b73b-c853-4723-b335-45ef95508a51
begin
    figure(3, figsize=(10,5), dpi=100);
    clf();
    map_e = imshow(data_e', origin="lower", vmin=0, vmax=200);
    colorbar(map_e);
    gcf()
end

# ╔═╡ Cell order:
# ╠═43661f9d-f832-4519-a85f-e1545b873cf2
# ╠═f83782f0-a2e2-11eb-0fec-d109f41f496b
# ╠═91967790-2c00-4289-a1d1-239f898442fa
# ╠═f1272e55-93c4-43f2-b953-3e2a1c463d3d
# ╠═b69b3d5c-79b2-4456-95e0-74fe5a8eb49b
# ╠═bff2b73b-c853-4723-b335-45ef95508a51
