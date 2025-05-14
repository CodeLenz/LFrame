@testset "YAML" begin
    
    ##############################################
    # File not exists
    @test_throws ErrorException LFrame.Le_YAML("data/no_exist.yaml")

    ##############################################
    # Empty file
    @test_throws ErrorException LFrame.Le_YAML("data/yaml/empty.yaml")

    ##############################################
    # Wrong version
    @test_throws ErrorException LFrame.Le_YAML("data/cantilever_point/cantilever_fx",1.1)

    # Dados obrigatórios
    # dados_obrigatorios=["coordenadas","conectividades","apoios","materiais","geometrias","dados_elementos"]

    ##############################################
    # No material 
    @test_throws ErrorException LFrame.Le_YAML("data/yaml/yaml_no_materiais.yaml")

    
end
