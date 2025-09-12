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
	include("K_portico.jl")
	include("esforcos.jl")
	include("apoios.jl")
	include("main.jl")
	include("exporta.jl")

    
	# Exporta a rotina principal de análise
	export Analise3D
	
	# Rotinas para calcular as forças nodais e as 
	# expressões dos esforços internos de cada elemento
	export Forcas_elemento, Esforcos_internos_elemento	
	
end
