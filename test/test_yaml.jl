@testset "YAML" begin

    # Path do LFrame 
    path_LFrame = dirname(dirname(pathof(LFrame)))

    # Path para o pacote LFrame
    caminho = joinpath(path_LFrame, "test")

    
    ##############################################
    # File not exists
    arquivo = joinpath([caminho,"data","yaml","no_exist.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)

    ##############################################
    # Empty file
    arquivo = joinpath([caminho,"data","yaml","empty.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)

    ##############################################
    # Wrong version
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_fx.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo,1.1)

    # Dados obrigatórios
    dados_obrigatorios=["coordenadas","conectividades","apoios","materiais","geometrias","dados_elementos"]

    ##############################################
    # No material 
    arquivo = joinpath([caminho,"data","yaml","yaml_no_materiais.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)

    ##############################################
    # No coordenadas
    arquivo = joinpath([caminho,"data","yaml","yaml_no_coordenadas.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)

    ##############################################
    # No apoios
    arquivo = joinpath([caminho,"data","yaml","yaml_no_apoios.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)
 
    ##############################################
    # No geometrias
    arquivo = joinpath([caminho,"data","yaml","yaml_no_geometrias.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)

    ##############################################
    # No dados_elementos
    arquivo = joinpath([caminho,"data","yaml","yaml_no_dados_elementos.yaml"])
    @test_throws ErrorException LFrame.Le_YAML(arquivo)

    ##############################################
    # Informa material que não existe em dados_elementos
    arquivo = joinpath([caminho,"data","yaml","yaml_consist_dados_elementos.yaml"])
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_consist_dados_elementos.yaml")


end
