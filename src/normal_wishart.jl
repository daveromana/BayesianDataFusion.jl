using Compat
using Distributions
using PDMats

import Base.LinAlg: Cholesky

immutable NormalWishart <: Distribution
    dim::Int
    zeromean::Bool
    mu::Vector{Float64}
    kappa::Float64
    Tchol::Cholesky{Float64}  # Precision matrix (well, sqrt of one)
    nu::Float64

    function NormalWishart(mu::Vector{Float64}, kappa::Real,
                                  Tchol::Cholesky{Float64}, nu::Real)
        # Probably should put some error checking in here
        d = length(mu)
        zmean::Bool = true
        for i = 1:d
            if mu[i] != 0.
                zmean = false
                break
            end
        end
        @compat new(d, zmean, mu, Float64(kappa), Tchol, Float64(nu))
    end
end

function NormalWishart(mu::Vector{Float64}, kappa::Real,
                       T::AbstractMatrix{Float64}, nu::Real)
    NormalWishart(mu, kappa, cholfact(T), nu)
end

function NormalWishart(mu::Vector{Float64}, kappa::Real,
                       T::PDMat, nu::Real)
    NormalWishart(mu, kappa, T.chol, nu)
end

import Distributions.rand

function rand(nw::NormalWishart)
    Lam = rand(Wishart(nw.nu, nw.Tchol))
    mu = rand(MvNormal(nw.mu, full(inv(Hermitian(Lam))) ./ nw.kappa))
    return (mu, Lam)
end