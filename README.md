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

## TODO 

## Mathematical Formulation ⚙️

In this section, we describe the mathematical framework used for topology optimization os 3D frame elements. The optimization problem is formulated to minimize the volume of the structure while satisfying constraints on stress and displacement.

### Objective Function:

### The constraints

### The Optimization Problem

### Sensivity Analysis






## Examples: 🛠️


<p align="center">
<img src="./docs/beam.jpeg"  width="300">
</p>
 
