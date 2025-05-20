@testset "YAML" begin
    
    ##############################################
    # File not exists
    @test_throws ErrorException LFrame.Le_YAML("test/data/no_exist.yaml")

    ##############################################
    # Empty file
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/empty.yaml")

    ##############################################
    # Wrong version
    @test_throws ErrorException LFrame.Le_YAML("test/data/cantilever_point/cantilever_fx",1.1)

    # Dados obrigatórios
    # dados_obrigatorios=["coordenadas","conectividades","apoios","materiais","geometrias","dados_elementos"]

    ##############################################
    # No material 
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_no_materiais.yaml")

    ##############################################
    # No coordenadas
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_no_coordenadas.yaml")

    ##############################################
    # No apoios
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_no_apoios.yaml")

    ##############################################
    # No geometrias
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_no_geometrias.yaml")

    ##############################################
    # No dados_elementos
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_no_dados_elementos.yaml")

    ##############################################
    # Informa material que não existe em dados_elementos
    @test_throws ErrorException LFrame.Le_YAML("test/data/yaml/yaml_consist_dados_elementos.yaml")


end
