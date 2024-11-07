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
   git clone [https://github.com/CodeLenz/LFrame]
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
```math
P  \left\{
    \begin{aligned}
    & min\; V(\bm{\rho}) \\
    & S.t \\
    & \quad \quad \mathbf{K}(\mathbf{\rho})\mathbf{U}(\mathbf{\rho}) = \mathbf{F} \\
    & \quad \quad \sigma_{eq,e} \leq \sigma_{limiting} \\
    & \quad \quad \mathbf{0} < \mathbf{\rho} \leq \mathbf{1} \\
    \end{aligned}
    \right.
```

Where


### Equação (3)
```math
   V(\bm{\rho}) = \sum_{e=1}^n \rho_e v^0_e
```
is the volume of the structure,
### Equação (4)
```math
  \mathbf{K}(\bm{\rho})=\cup_{e=1}^{n} \rho_e^p \mathbf{K}^0_e
```
- \( \mathbf{K}(\bm{\rho}) \) is the global stiffness matrix, obtained by assembling the individual stiffness matrices \( \mathbf{K}_e^0 \) of the elements, scaled by the design variables \( \rho_e^p \).
- \( \cup \) is the assembly operator that combines the elemental stiffness matrices to form the global matrix.
- \( v_e^0 \) is the volume of element \( e \).
- \( \mathbf{U} \) is the displacement vector, representing the displacements of the nodes of the structure.
- \( \mathbf{F} \) is the force vector, representing the applied loads on the structure.
- \( \sigma_{eq,e} \) is the **Von Mises equivalent stress** at element \( e \)
- \( \sigma_{\text{limiting}} \) is the limiting stress, calculated considering the **yield stress** \( \sigma_{\text{yield}} \) of the material and a **safety factor** \( \text{FS} \). It is the maximum allowable stress in the system.
  - Specifically: 
    ```math
    \sigma_{\text{limiting}} = \frac{\sigma_{\text{yield}}}{\text{n}}
    ```

Through the augmented Lagrangian approach, the optimization problem, in its streamlined form, as well as with the adjoint method, can be written as
### Equação (5)
```math
   L_A = V  + \frac{c_{\sigma}}{2(4ne)} \sum_{e=1}^{ne} \sum_{no=1}^{2}\sum_{a=0}^{1}\left< \frac{\mu_i}{c}+g_{\sigma j} \right>^2 + \bm{\lambda}^T(\mathbb{K}\mathbf{U} - \mathbf{F})
```
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
 
