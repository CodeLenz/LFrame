# LFrame - Topology Optimization of Spatial Frames 📐

<p align="center">
<img src="./docs/spatttttttial.png">
</p>

This repository contains the codes developed for the undergraduate research project aimed at optimizing structures composed of 3D frame elements, without performance loss as material is removed.

## About Our Project :rocket:

Using the Finite Element Method, we implemented Topology Optimization techniques for elements with six degrees of freedom per node. Our goal is to minimize the structure's volume while imposing constraints on stress and displacement.

### Key Points :sparkles:

- Modeling of frame elements
- Objective function: currently, minimizing the total volume of the structure
- Use of the Augmented Lagrangian Method, through the Adjoint Problem approach
- Utilization of visualization tools for mesh generation and results
- Easy implementation of examples for validation

### How it works :sunglasses:

  - We define the problem in a `.yaml` file
  - We perform the initial analysis using FEM
  - The optimization and sensitivity analysis process begins
  - We check for convergence
  - If the process is completed, a `.pos` file for visualization, compatible with the open-source software Gmsh, is generated.

## How to use :computer:
### Requirements:
- Julia Language
- The module `Viga3D`
- Other dependencies can be found in 'colocar aq'

### Installation:
1. First, clone the repository:
    ```bash
   git clone https://github.com/your-repo/LFrame.git
2. Navigate to the repository directory:
   ```bash
   cd("...\\LFrame")
3. Install the required Julia packages
   ```bash
   ]instantiate()
   ```

### Running an Example:
To run an exemple, simply use
```bash
  include("examples/example123.yaml")
```

This will perform an initial FEM analysis and start the optimization process. After the procedure is complete, a `.pos` file is generated for visualization in Gmsh. To view the results,
1. Open Gmsh
2. In the File menu, click Open
3. Navigate to the folder of the examples, the file will be generated there
4. Select the file

## Mathematical Formulation ⚙️

In this section, we describe the mathematical framework used for topology optimization os 3D frame elements. The optimization problem is formulated to minimize the volume of the structure while satisfying constraints on stress, using the SIMP approach.

### Equação (1)
![Fórmula](https://latex.codecogs.com/png.latex?%5Cmathbf%7BK%7D_e%28%5Crho_e%29%20%3D%20%5Crho%5Ep_e%20%5Cmathbf%7BK%7D_e%5E0)

where $ \mathbf{K}_e^0 $ is the stiffness matrix evaluated using $ E^0 $.
The Optimization Problem is defined as

### Equação (2)
![Fórumula](https://latex.codecogs.com/png.latex?P%20%20%5Cleft%5C%7B%0A%20%20%20%20%5Cbegin%7Baligned%7D%0A%20%20%20%20%26%20min%5C%20V%28%5Cbm%7B%5Crho%7D%29%20%5C%5C%0A%20%20%20%20%26%20S.t%20%5C%5C%0A%20%20%20%20%26%20%20%20%20%5Cmathbf%7BK%7D%28%5Cbm%7B%5Crho%7D%29%5Cmathbf%7BU%7D%28%5Cbm%7B%5Crho%7D%29%20%3D%20%5Cmathbf%7BF%7D%20%5C%5C%0A%20%20%20%20%26%20%20%20%20%5Csigma_%7Beq%2Ce%7D%20%5Cleq%20%5Csigma_%7Blimiting%7D%20%5C%5C%0A%20%20%20%20%26%20%20%20%20%5Cmathbf%7B0%7D%20%3C%20%5Cbm%7B%5Crho%7D%20%5Cleq%20%20%5Cmathbf%7B1%7D%20%5C%5C%0A%20%20%20%20%5Cend%7Baligned%7D%0A%5Cright%7D

Where


### Equação (3)
![Volume](https://latex.codecogs.com/png.latex?V%28%5Cbm%7B%5Crho%7D%29%20%3D%20%5Csum_%7Be%3D1%7D%5En%20%5Crho_e%20v_e%5E0)
is the volume of the structure,
### Equação (4)
![Matriz de Rigidez Global](https://latex.codecogs.com/png.latex?%5Cmathbf%7BK%7D%28%5Cbm%7B%5Crho%7D%29%20%3D%20%5Ccup_%7Be%3D1%7D%5En%20%5Crho_e%5Ep%20%5Cmathbf%7BK%7D_e%5E0)

- \( \mathbf{K}(\bm{\rho}) \) is the global stiffness matrix, obtained by assembling the individual stiffness matrices \( \mathbf{K}_e^0 \) of the elements, scaled by the design variables \( \rho_e^p \).
- \( \cup \) is the assembly operator that combines the elemental stiffness matrices to form the global matrix.
- \( v_e^0 \) is the volume of element \( e \).
- \( \mathbf{U} \) is the displacement vector, representing the displacements of the nodes of the structure.
- \( \mathbf{F} \) is the force vector, representing the applied loads on the structure.
- \( \sigma_{eq,e} \) is the **Von Mises equivalent stress** at element \( e \)
- \( \sigma_{\text{limiting}} \) is the limiting stress, calculated considering the **yield stress** \( \sigma_{\text{yield}} \) of the material and a **safety factor** \( \text{FS} \). It is the maximum allowable stress in the system.
  - Specifically: 
    \[
    \sigma_{\text{limiting}} = \frac{\sigma_{\text{yield}}}{\text{n}}
    \]

Through the augmented Lagrangian approach, the optimization problem, in its streamlined form, as well as with the adjoint method, can be written as
### Equação (5)
![Lagrangian](https://latex.codecogs.com/png.latex?L_A%20%3D%20V%20%20%2B%20%5Cfrac%7Bc_%7B%5Csigma%7D%7D%7B2%284ne%29%7D%20%5Csum_%7Be%3D1%7D%5Ene%20%5Csum_%7Bno%3D1%7D%5E2%5Csum_%7Ba%3D0%7D%5E1%5Cleft%3C%20%5Cfrac%7B%5Cmu_i%7D%7Bc%7D%2Bg_%7B%5Csigma%20j%7D%20%5Cright%3E%5E2%20%2B%20%5Cbm%7B%5Clambda%7D%5ET%28%5Cmathbb%7BK%7D%5Cmathbf%7BU%7D%20-%20%5Cmathbf%7BF%7D%29)

Where:
- \( L_A \) is the augmented Lagrangian function.
- \( V \) is the volume.
- \( c_{\sigma} \) is a constant related to the stress penalty term.
- The double summation represents the contribution of each element, node, and degree of freedom to the total penalization term.
- \( \mu_i \) is a parameter related to the perturbation of the design variables.
- \( g_{\sigma j} \) is the stress constraint function.
- \( \bm{\lambda} \) is the vector of Lagrange multipliers.
- \( \mathbb{K} \) is the global stiffness matrix.
- \( \mathbf{U} \) is the displacement vector.
- \( \mathbf{F} \) is the force vector.

We can observe the importance of the objective function and the constraints through sensitivity analysis, using the derivatives of these functions. In this way, we can analyze how perturbations in these functions affect the optimization problem.
### TODO




## Examples: 🛠️
![Em Construção]([https://url-da-imagem.com/imagem.png](https://pngimg.com/d/under_construction_PNG18.png))


<p align="center">
<img src="./docs/beam.jpeg"  width="300">
</p>
 
