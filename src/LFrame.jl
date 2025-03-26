module LFrame

	using LinearAlgebra
	using SparseArrays
	using LinearSolve
	using OrderedCollections
    using YAML
	using Lgmsh
	
	# Carregando as outras rotinas:
	include("struct_malha.jl")
	include("auxiliar.jl")
	include("leitura_dados.jl")
	include("pre_processamento.jl")
	include("rotacao.jl")
	include("global.jl")
	include("Kg_portico.jl")
	include("esforcos.jl")
	include("apoios.jl")
	include("main.jl")

	# Exporta a rotina principal de análise
	export Analise3D
	
end
