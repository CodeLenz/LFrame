#
# Tests to verify the stiffness matrix of a single element 
# in the XY plane
#
@testset "Cantilever point loads - Plane XY" begin
    
    # Path do LFrame 
    path_LFrame = dirname(dirname(pathof(LFrame)))

    # Path para o pacote LFrame
    caminho = joinpath(path_LFrame, "test")

    ##############################################
    # FX (axial - bar)
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_fx.yaml"])
    U,_ = Analise3D(arquivo,false)

    # Verifica a resposta
    @test U[7] ≈  1.0
 

    ##############################################
    # FY (beam)
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_fy.yaml"])
    U,_ = Analise3D(arquivo,false)

    # Verifica as respostas
    @test U[8]  ≈ 0.4
    @test U[12] ≈ 0.3


    ##############################################
    # FZ (beam)
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_fz.yaml"])
    U,_ = Analise3D(arquivo,false)

    # Verifica as respostas
    @test U[9]  ≈   1.6
    @test U[11] ≈  -1.2

  
    ##############################################
    # MX (torsion)
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_mx.yaml"])
    U,_ = Analise3D(arquivo,false)

    # Verifica as respostas
    @test U[10]  ≈   8.888888888888


    ##############################################
    # MY 
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_my.yaml"])
    U,_ = Analise3D(arquivo,false)

    # Verifica as respostas
    @test U[9]   ≈   -12.0
    @test U[11]  ≈    12.0
 

    ##############################################
    # MZ 
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_mz.yaml"])
    U,_ = Analise3D(arquivo,false)

    # Verifica as respostas
    @test U[8]   ≈    3.0
    @test U[12]  ≈    3.0


end
