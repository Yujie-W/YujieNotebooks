### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ c5645815-ca76-4761-9e18-014d7c70addc
using Pkg; Pkg.activate("../Project.toml");

# ╔═╡ 0c33d996-a2b6-11eb-1b66-9b4b92d4ddad
using ConstrainedRootSolvers,PyPlot

# ╔═╡ 59e50a29-06e6-4872-bef8-bd6732946295
md"
# ConstrainedRootSolvers.find_zero
First of all, install the packages if it has not been installed
```julia
using Pkg
Pkg.add(\"ConstrainedRootSolvers\")
```

First, activate the project environment, and then import the packages required
"

# ╔═╡ 81ec6dd7-033b-49f5-b754-87ad199fa101
md"
`ConstrainedRootSolvers` provides two solver functions:
- find_zero
- find_peak

Now let's start with `find_zero` function by defining a few functions to work on. Note that `find_zero` and `find_peak` are meant to find the minimum value that meets the requirement. Let us define a function now. Function 1 with two solutions at 1 and 3:
"

# ╔═╡ 5a782e80-0f26-476c-8877-5d4ff9519d2a
function f_zero_1(x::FT) where {FT<:AbstractFloat}
    return (x-2)^2 - 1
end;

# ╔═╡ 2a14b335-7169-43ec-8ce2-54d807efcb74
md"
Now let us plot out what the function is like in the range of [0,2.5]. Before that, we may define a function to plot the results so as to avoid repeating the code again and again...
"

# ╔═╡ b6c4f63e-73c9-406b-b90f-65c6a58790f5
"""
    preview_results(
                n::Int,
                x_min::FT,
                x_max::FT,
                f::Function;
                fcolor::String = "gray"
    ) where {FT<:AbstractFloat}
    preview_results(
                n::Int,
                x_min::FT,
                x_max::FT,
                f::Function,
                h::Vector;
                fcolor::String = "gray"
    ) where {FT<:AbstractFloat}

Preview the results, given
- `n` Figure number
- `x_min` Minimum x
- `x_max` Maximum x
- `h` Vector of history
- `fcolor` Face color (background) of the plot. Default is "gray".
"""
function preview_results(
            n::Int,
            x_min::FT,
            x_max::FT,
            f::Function;
            fcolor::String = "gray"
) where {FT<:AbstractFloat}
    # plot the function
    xs = collect(Float32, x_min:0.05:x_max);
    ys = f_zero_1.(xs);
    fig = figure(n, figsize=(6,4), dpi=100);
    fig.patch.set_facecolor(fcolor);
    ax1 = fig.add_subplot(1,1,1);
    ax1.set_facecolor(fcolor);
    ax1.plot(xs, ys, "k-");
    ax1.plot(xs, xs*0, "k:");
    ax1.set_xlabel("X");
    ax1.set_ylabel("Y");
    return fig
end;

# ╔═╡ 09ff17b5-2fcd-4c04-8cae-06d9823cb66a
function preview_results(
            n::Int,
            x_min::FT,
            x_max::FT,
            f::Function,
            h::Vector;
            fcolor::String = "gray"
) where {FT<:AbstractFloat}
    # plot the function
    xs = collect(Float32, x_min:0.05:x_max);
    ys = f_zero_1.(xs);
    fig = figure(n, figsize=(6,4), dpi=100);
    fig.patch.set_facecolor(fcolor);
    ax1 = fig.add_subplot(1,1,1);
    ax1.set_facecolor(fcolor);
    ax1.plot(xs, ys, "k-");
    ax1.plot(xs, xs*0, "k:");
    ax1.set_xlabel("X");
    ax1.set_ylabel("Y");
    # plot the steps
    _xs = [_xy[1] for _xy in h];
    _ys = [_xy[2] for _xy in h];
    ax1.plot(_xs, _ys, "r.");
    return fig
end;

# ╔═╡ c3a9a585-86c3-477f-8afa-583f288f59a6
preview_results(1, Float32(0), Float32(2.5), f_zero_1)

# ╔═╡ b66aadd3-4765-4e55-92e1-65ffb67c8086
md"
Now, we may try to use the solver to do it. The supported methods for `find_zero` are meant to solve for 1D problems, and include the following
- Bisection Method
- Newton Raphson Method
- Fusion of Besection and Newton Raphson Method
- Reduce Steo Method

Besides the solver method, we also need a tolerance for solution or residual, and only when the solution or residual is smaller than the target value, we consider the solution is found. The supported tolerances for find_zero are
- Residual Tolerance
- Solution Tolerance

In the sections below, we will try them one by one. Let's start with Bisection method and a solution tolerance. When a solution tolerance is used, the solution is considered to be found when the difference between two trial x values is lower than the target value. Further, there is a maximum limit for the number of iterations.
"

# ╔═╡ 89cbcf83-73b8-4320-8015-cba87c542dc2
begin
    ms_bis = BisectionMethod{Float32}(x_min=0, x_max=2.5);
    tol_sl = SolutionTolerance{Float32}(1e-4, 50);
    sol_1 = find_zero(f_zero_1, ms_bis, tol_sl);
    @show sol_1,f_zero_1(sol_1);
end

# ╔═╡ 8a7621a3-7633-4f70-82fc-816486c4fac8
md"
We may now try to visualize what the Bisection solver has done by enable the stepping record. In this case, the history is stored in the `history` field in the method.

Yet, keep in mind that unless you want to visualize the history, otherwise do not enable the history option, because the saving history step uses computation resources.

The example below plots the history of the Bisection method.
"

# ╔═╡ a1e2db7f-d939-4cfb-bb08-9e872c4b97f3
begin
    sol_2 = find_zero(f_zero_1, ms_bis, tol_sl; stepping=true);
    preview_results(2, Float32(0), Float32(2.5), f_zero_1, ms_bis.history)
end

# ╔═╡ eb50448e-fa8b-4f6b-9b37-19e032e64df1
md"
This time let's try to visualize the Newton Raphson method. However, this method does not support setting up min and max x. Newton raphson method is much faster than Bisection Method, if you choose a right start point.
"

# ╔═╡ 3fce4a28-c1fc-41ad-a91c-845c3912bd35
begin
    ms_ntr = NewtonRaphsonMethod{Float32}(x_ini=0.0);
    sol_3 = find_zero(f_zero_1, ms_ntr, tol_sl; stepping=true);
    preview_results(3, Float32(0), Float32(2.5), f_zero_1, ms_ntr.history)
end

# ╔═╡ 6a31fb04-2428-4c3f-a97f-1095a579e55e
md"
However, if you start from a wrong point, the method might take you to a incorrect answer. For example, we let the initial point start from 2.1 this time.
"

# ╔═╡ 977d9e4d-1f9a-4c9b-8e27-65c808ff98fe
begin
    ms_ntt = NewtonRaphsonMethod{Float32}(x_ini=2.1);
    sol_4 = find_zero(f_zero_1, ms_ntt, tol_sl; stepping=true);
    preview_results(4, Float32(0), Float32(2.5), f_zero_1, ms_ntt.history)
end

# ╔═╡ 87b508a3-d2df-4c94-8e5b-5562beaa3163
md"
To better utilize the speed of Newton raphson and the constraints from Bisection method, we may use the fusion method. This method does not really care where is your initial guess, because the range of x is fixed by Bisection method. If the Newton Raphson method gives an x value out of the range, Bisection method will be used. here is the first case when we start from a good initial guess.
"

# ╔═╡ d247f0fe-e72f-45e4-8fb7-6146e135e3e1
begin
    ms_nb1 = NewtonBisectionMethod{Float32}(x_min=0.0, x_max=2.5, x_ini=0.0);
    sol_5 = find_zero(f_zero_1, ms_nb1, tol_sl; stepping=true);
    preview_results(5, Float32(0), Float32(2.5), f_zero_1, ms_nb1.history)
end

# ╔═╡ 3832fe4c-d160-4da1-818c-351fe9475d35
md"
As I said, the method also works when we start from 2.1 (a bad initial guess for normal Newton Raphson method).
"

# ╔═╡ 4dbea0d0-dded-4507-bd1c-f016812bb0e1
begin
    ms_nb2 = NewtonBisectionMethod{Float32}(x_min=0.0, x_max=2.5, x_ini=2.1);
    sol_6 = find_zero(f_zero_1, ms_nb2, tol_sl; stepping=true);
    preview_results(6, Float32(0), Float32(2.5), f_zero_1, ms_nb2.history)
end

# ╔═╡ e0689593-0a82-42a3-b720-6c7266b745c3
md"
We also have reduce step method. What this method does is to increment (increase or decrease) the x by a certain step, until we find the best solution. Then we reduce the step by 10 times. We repeat this progress until we find the solution. Note that we use the abs(y) in the method, and try to find minimum abs(y). Thus, at each step, we start from the x that gives lowest abs(y). Let us now start with an initial step of 1.
"

# ╔═╡ d637113b-0162-4987-8b74-444d5a9af5c1
begin
    ms_rst = ReduceStepMethod{Float32}(x_min=0, x_max=2.5, x_ini=0.5, Δ_ini=1);
    sol_7 = find_zero(f_zero_1, ms_rst, tol_sl; stepping=true);
    preview_results(7, Float32(0), Float32(2.5), f_zero_1, ms_rst.history)
end

# ╔═╡ 6d6bf0b3-b4df-49a1-a733-c632ff7ef1dc
md"
I would like to note that we have been using solution tolerance in the examples above. The residual tolerance works as well, and here is the example. Here we set a tolerance of 1e-4, meaning that when the abs(y) should be lower than 1e-4. You may try out the residual tolerance with other methods on your own.
"

# ╔═╡ 323aec6a-a921-4d97-aa8a-54104f82d150

begin
    tol_rs = ResidualTolerance{Float32}(1e-4, 50);
    sol_8 = find_zero(f_zero_1, ms_bis, tol_rs);
    @show sol_8,f_zero_1(sol_8);
end

# ╔═╡ Cell order:
# ╟─59e50a29-06e6-4872-bef8-bd6732946295
# ╠═c5645815-ca76-4761-9e18-014d7c70addc
# ╠═0c33d996-a2b6-11eb-1b66-9b4b92d4ddad
# ╟─81ec6dd7-033b-49f5-b754-87ad199fa101
# ╠═5a782e80-0f26-476c-8877-5d4ff9519d2a
# ╟─2a14b335-7169-43ec-8ce2-54d807efcb74
# ╠═b6c4f63e-73c9-406b-b90f-65c6a58790f5
# ╠═09ff17b5-2fcd-4c04-8cae-06d9823cb66a
# ╠═c3a9a585-86c3-477f-8afa-583f288f59a6
# ╟─b66aadd3-4765-4e55-92e1-65ffb67c8086
# ╠═89cbcf83-73b8-4320-8015-cba87c542dc2
# ╟─8a7621a3-7633-4f70-82fc-816486c4fac8
# ╠═a1e2db7f-d939-4cfb-bb08-9e872c4b97f3
# ╟─eb50448e-fa8b-4f6b-9b37-19e032e64df1
# ╠═3fce4a28-c1fc-41ad-a91c-845c3912bd35
# ╟─6a31fb04-2428-4c3f-a97f-1095a579e55e
# ╠═977d9e4d-1f9a-4c9b-8e27-65c808ff98fe
# ╟─87b508a3-d2df-4c94-8e5b-5562beaa3163
# ╠═d247f0fe-e72f-45e4-8fb7-6146e135e3e1
# ╟─3832fe4c-d160-4da1-818c-351fe9475d35
# ╠═4dbea0d0-dded-4507-bd1c-f016812bb0e1
# ╟─e0689593-0a82-42a3-b720-6c7266b745c3
# ╠═d637113b-0162-4987-8b74-444d5a9af5c1
# ╟─6d6bf0b3-b4df-49a1-a733-c632ff7ef1dc
# ╠═323aec6a-a921-4d97-aa8a-54104f82d150
