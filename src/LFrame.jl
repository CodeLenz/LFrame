module LFrame

	using LinearAlgebra
	using SparseArrays
	using LinearSolve
	using OrderedCollections
    using YAML
	#using BMesh
	#using WallE
	#using Lgmsh
	
	# Carregando as outras rotinas:
	include("auxiliar.jl")
	include("leitura_dados.jl")
	include("pre_processamento.jl")
	include("rotacao.jl")
	include("global.jl")
	include("Kg_portico.jl")
	include("esforcos.jl")
	include("apoios.jl")
	#include("visualizacao.jl")
	
    # Otimização
	#include("otm/criterio.jl")
	#include("otm/volume.jl")
	#include("otm/flex.jl")
	#include("otm/driver_volume_desloc.jl")
	#include("otm/golden.jl")
	#include("otm/steepest.jl")
	#include("otm/dlambda.jl")
	#include("otm/df.jl")

	#include("main_volume_desloc.jl")
	#export Otimiza_Portico3D_volume_desloc

	include("main.jl")
	export Analise3D

end
