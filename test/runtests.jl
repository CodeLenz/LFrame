using LFrame
using Test

# Testes da entrada de dados
include("test_yaml.jl")

# Testes com viga engastada e carregamentos concentrados
include("test_cantilever_plane.jl")