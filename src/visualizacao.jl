# programa de teste pra tentar rodar o gmsh...

# Começando com a criação da malha...

# Vou usar a rotina do BMesh, lembrando q o nosso elemento é o 1

# Copy & paste do repositorio......

function Bmesh_truss_3D(Lx::Float64,nx::Int64,Ly::Float64,ny::Int64,Lz::Float64,nz::Int64;
                        origin=(0.0,0.0,0.0))

    # Assertions
    @assert Lx>0 "Bmesh_truss_3D:: Lx must be > 0"
    @assert Ly>0 "Bmesh_truss_3D:: Ly must be > 0"
    @assert Lz>0 "Bmesh_truss_3D:: Lz must be > 0"

    @assert nx>=1 "Bmesh_truss_3D:: nx must be >= 1"
    @assert ny>=1 "Bmesh_truss_3D:: ny must be >= 1"
    @assert nz>=1 "Bmesh_truss_3D:: nz must be >= 1"

    # number of nodes in each Z (XY planes)
    nn_plane = (nx+1)*(ny+1)

    # The number of nodes is a function of both nx, ny and nz
    nn = (nz+1)*nn_plane

    # The number of elements is also a function of nx and ny, and also
    # of the connectivity among the nodes. Lets consider a simple X
    # connectivity in each Z plane and additional cross links
    # in each "cube"

    # Number of elements in each Z (XY planes)
    #      barras h     barras vert   barras diagonais
    ne_plane =   nx*(ny+1) +   ny*(nx+1) +      2*nx*ny

    # Number of "vertical" Z elements
    ne_vz = (nx+1)*(ny+1)*nz

    # Number of "diagonal" / YZ elements (planes em X)
    # the number of \ elements is the same in this plane
    ne_d_yz = 2*nz*(nx+1)*ny

    # Number of "diagonal" \ XZ elements (planes em Y)
    # the number of / elements is the same in this plane
    ne_d_xz = 2*nz*(nx)*(ny+1)

    # Number of inner elements (in each "cube)
    ne_int = 4*(nx*ny*nz)

    # Total number of elements
    ne = (nz+1)*ne_plane + ne_vz + ne_d_yz + ne_d_xz + ne_int

    # Now lets define two arrays. The first one contains the node
    # coordinates and the second one the connectivities
    coord = zeros(nn,3)
    connect = zeros(Int64,ne,2)

    # Increments of each coordinate
    dx = Lx/nx
    dy = Ly/ny
    dz = Lz/nz

    # Initial coordinates
    x = origin[1]-dx  
    y = origin[2]-dy
    z = origin[3]-dz

    # Lets generate the coordinates, bottom to top, left to rigth
    cont = 0
    # Loop em Z
    for k=1:nz+1
        z += dz
        # Loop em Y
        for i=1:ny+1
            # Increment y (row)
            y += dy
            # Loop em X
            for j=1:nx+1
                # increment x (column)
                x += dx
                # Increment counter
                cont += 1
                # Store the coordinate
                coord[cont,1] = x
                coord[cont,2] = y
                coord[cont,3] = z
            end #j
            # reset x
            x = origin[1]-dx
        end #i
        # Reset both x and y (start a new plane) 
        x = origin[1]-dx
        y = origin[2]-dy
    end #k

    #
    #
    # Now that we have the coordinates, lets generate the connectivities.
    #
    #
    # The basic block is generated for each Z plane (horizontal (X), vertical (Y) and 
    #  diagonals in the plane XY (Z constant)). We then move to the next Z plane and 
    #  so on. Then, we proceed with the interplane connectivities
    #
    #
    #
    #

    # First, lets generate horizontal bars
    #
    #   nx = 3 e ny = 2
    #
    #
    #   (9)----(10)-----(11)-----(12)
    #    |       |       |        |
    #   (5)-----(6)-----(7)------(8)
    #    |       |       |        | 
    #   (1)-----(2)-----(3)------(4)
    #
    #

    # Element counter
    cont = 0

    # Loop
    for k=0:nz

        # Start a new plane
        no1 = 0 + k*nn_plane
        no2 = 1 + k*nn_plane

        # Horizontal elements (X)
        for i=1:ny+1
            for j=1:nx

                # Increment node numbers
                no1 += 1
                no2 += 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j

            # We finished a row. Lets increment the nodes by 1
            no1 += 1
            no2 += 1
        end #i

            # Vertical elements (Y)
            no1 = 0 + k*nn_plane
            no2 = nx+1 + k*nn_plane
        for i=1:ny
            for j=1:nx+1
                # Increment node numbers
                no1 += 1
                no2 += 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j
        end #i

        # Now, lets generate the / bars
        no1 = 0 + k*nn_plane
        no2 = nx+2 + k*nn_plane
        for i=1:ny
            for j=1:nx

                # Increment node numbers
                no1 += 1
                no2 += 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j
            no1 += 1
            no2 += 1
        end #i

        # And, finally, the \ bars
        no1 = 1 + k*nn_plane
        no2 = nx+1 + k*nn_plane
        for i=1:ny
            for j=1:nx

                # Increment node numbers
                no1 += 1
                no2 += 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j
            no1 += 1
            no2 += 1
        end #i
    end #k

    #
    # OK. Inter plane elements
    #

    # Vertical (Z) direction
    # Loop
    for k=1:nz

        # Start between planes k and k+1 and 
        no1 = (k-1)*nn_plane
        no2 = k*nn_plane

        # Vertical elements (Z)
        for i=1:ny+1
            for j=1:nx+1

                # Increment node numbers
                no1 += 1
                no2 += 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j

        end #i

    end

    ######################################## YZ ##############################################

    # Diagonals / in the YZ planes
    # as looking from the positive X axis
    # Loop
    for k=1:nz

        # / in YZ planes
        for j=1:nx+1

            for i=1:ny

                # Nodes
                no1 = j + (nx+1)*(i-1) + (k-1)*nn_plane
                no2 = k*nn_plane + j + (nx+1)*i


                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j

        end #i

    end


    # Diagonals \ in the YZ planes
    # as looking from the positive X axis
    # Loop
    for k=1:nz

        # / in YZ planes
        for j=1:nx+1

            for i=1:ny

                # Nodes
                no1 = j + (nx+1)*i + (k-1)*nn_plane
                no2 = k*nn_plane + j + (nx+1)*(i-1)

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j

        end #i

    end

    ########################################### XZ #####################################

    # Diagonals \ in the XZ planes
    # as looking from the positive Y axis
    # Loop
    for k=1:nz

        # / in YZ planes
        for i=1:ny+1

            for j=1:nx

                # Nodes
                no1 = j + (nx+1)*(i-1) + (k-1)*nn_plane
                no2 = no1 + nn_plane + 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j

        end #i

    end

    # Diagonals / in the XZ planes
    # as looking from the positive Y axis
    # Loop
    for k=1:nz

    # / in YZ planes
        for i=1:ny+1

            for j=1:nx

                # Nodes
                no1 = j + (nx+1)*(i-1) + (k-1)*nn_plane + 1
                no2 = no1 + nn_plane - 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2
            end #j

        end #i

    end


    ################################# INTERNALS ####################################
    #
    # Each "cube" has 4 internal elements linking the four corner nodes
    #
    # Loop
    for k=1:nz

        for i=1:ny

            for j=1:nx

                #
                # First element - Forward (X) diagonal
                #
                no1 = j + (nx+1)*(i-1) + (k-1)*nn_plane
                no2 = k*nn_plane + j + (nx+1)*i + 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2

                #
                # Second element - Backward (X) diagonal
                #
                no1 = no1 + 1
                no2 = no2 - 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2

                #
                # Third element - Forward (Y) diagonal
                #
                no1 = no1 + nn_plane
                no2 = no2 - nn_plane

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1
                connect[cont,2] = no2

                #
                # Fourth element - Backward (Y) diagonal
                #
                no1 = no1 - 1
                no2 = no2 + 1

                # Increment counter
                cont += 1

                # Store the connectivity
                connect[cont,1] = no1 
                connect[cont,2] = no2 

            end #j

        end #i

    end


    # Creates the datatype
    bmesh = Bmesh3D(:truss3D,nn,ne,coord,connect, Lx, Ly, Lz, nx, ny, nz)

    # Return bmesh
    return bmesh

end

# Beleza, agora vamos pra parte do gmsh...

# Copy & paste de novo...

#
# Cria o cabecalho com informacoes da malha
# para posterior adicao de vistas com saidas
#
function Gmsh_init(nome_arquivo::String,bmesh::Bmesh)

    
    # Verifica se já existe o arquivo, se sim, remove
    if isfile(nome_arquivo); rm(nome_arquivo); end

    # Abre o arquivo para escrita
    saida = open(nome_arquivo,"a")

    # Dimension (2/3)
    dim = 2
    if isa(bmesh,Bmesh3D)
        dim = 3
    end
    
    # Number of nodes
    nn = bmesh.nn

    # Number of elements
    ne = bmesh.ne

    # Cabecalho do gmsh
    println(saida,"\$MeshFormat")
    println(saida,"2.2 0 8")
    println(saida,"\$EndMeshFormat")

    # Nodes
    println(saida,"\$Nodes")
    println(saida,nn)
    if dim==2
        for i=1:nn
            println(saida,i," ",bmesh.coord[i,1]," ",bmesh.coord[i,2]," 0.0 ")
        end
    else
        for i=1:nn
            println(saida,i," ",bmesh.coord[i,1]," ",bmesh.coord[i,2]," ",bmesh.coord[i,3])
        end
    end    
    println(saida,"\$EndNodes")

    # Element type (gmsh code)
    tipo_elemento = 1
    if bmesh.etype==:solid2D
        tipo_elemento = 3
    elseif bmesh.etype==:solid3D
        tipo_elemento = 5    
    end

    println(saida,"\$Elements")
    println(saida,ne)
    for i=1:ne 
        con = string(i)*" "*string(tipo_elemento)*" 0 "*string(bmesh.connect[i,1])
        for j=2:size(bmesh.connect,2)
            con = con * " " * string(bmesh.connect[i,j])
        end
        println(saida,con)
    end
    println(saida,"\$EndElements")

    # Fecha o arquivo ... por hora
    close(saida)


end 

# Agora vamos usar o pacote Lgmsh :)

#  Copy & paste do exemplo...

function Lgmsh_init(arquivo)
    # Path to the mesh file
    filename = joinpath(pathof(Lgmsh)[1:end-12],arquivo)

    # Obtain nodes and coordinates
    # This model has 10 nodes
    nn, norder, coord = Lgmsh_import_coordinates(filename)

    # Obtain the list of element types
    # this file has elements of type 1,2,3 and 15
    etypes = Lgmsh_import_etypes(filename)

    # Obtain the information about the 2-node line element (type 1)
    ne, number, connect =  Lgmsh_import_element_by_type(filename,1)

    # Obtain the Physical Groups and names
    # This file has 3 Physical Groups
    # (0, 5) named "u,all,0.0"
    # (1, 6) named "p,n,100.0"
    # (2, 7) named "material"
    pgroups, pgnames = Lgmsh_import_physical_groups(filename)

    # Obtain the entities with "p,n,100.0"
    entities = Lgmsh_import_entities_physical_group(filename,pgnames[2])
end

