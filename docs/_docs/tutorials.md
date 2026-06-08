---
title: Tutorials
author: Tatsumi Imada
date: 2025-10-03
category: Jekyll
layout: post
toc:
    enabled: true
---

# Before you start
Pre-analyzed example data can be found in the ```tutorials``` folder of the [GitHub repository](https://github.com/metabolic-engineering/OpenMebius2).
Before we analyze your own data, you can try to reproduce the results of these examples to get familiar with the workflow of OpenMebius2.

# Installation
1. Go to the [GitHub repository](https://github.com/metabolic-engineering/OpenMebius2) and download the repository as a ZIP file by clicking the green ```Code``` button and selecting ```Download ZIP```. If you are familiar with Git, you can also clone the repository by using the following command:
    ```bash
    git clone https://github.com/metabolic-engineering/OpenMebius2.git
    ```

{: align="center"}
![download_zip](../../assets/images_tutorials/result_sample_0.png)

2. Unzip the downloaded ZIP file and navigate to the ```OpenMebius2/installer``` folder. This folder contains the installer for OpenMebius2. Click the installer file (depending on your operating system) to install OpenMebius2 on your computer (administrative privileges may be required). 
3. Start OpenMebius2 program by double-clicking the OpenMebius2 icon on your desktop or in your applications folder.

# Opening example projects
1. Start OpenMebius2 program.
2. Click the ```Browse``` button in the ```Project``` field on the top left of the window.

{: align="center"}
![browse_project](../../assets/images_tutorials/result_sample_1.png)

1. Navigate to the ```tutorials/ecoli``` folder in the unzipped ```OpenMebius2``` directory. Click the ```Select Folder``` button to open the example project.

{: align="center"}
<img src="../../assets/images_tutorials/result_sample_2.png" alt="open_project" width="640"/>

4. Click the ```Load``` button to load the example project.

{: align="center"}
![load_project](../../assets/images_tutorials/result_sample_3.png)

5. The example project is now loaded, and you can select ```Result``` tab to view the analysis results.

{: align="center"}
<img src="../../assets/images_tutorials/result_sample_4.png" alt="result_tab" width="640"/>

1. By clicking the desired row in the result table, you can view fluxes and upper/lower bounds calculated by flux variability analysis (FVA).

{: align="center"}
<img src="../../assets/images_tutorials/result_sample_5.png" alt="fva_result" width="640"/>
<img src="../../assets/images_tutorials/result_sample_6.png" alt="flux_map" width="640"/>

1. Choose the ```Details``` item in the drop-down menu on the top of the result table to view simulated and measured mass distribution vectors (MDVs) for each metabolite.

{: align="center"}
<img src="../../assets/images_tutorials/result_sample_7.png" alt="detailed_result" width="640"/>

1. You can compare fluxes of different results by selecting multiple rows in the result table while holding the ```Ctrl``` key (or ```Cmd``` key on Mac) and clicking the ```Comparison``` button above the table.

{: align="center"}
<img src="../../assets/images_tutorials/result_sample_8.png" alt="compare_fluxes" width="640"/>

1. You can also visualize flux maps on the right side of the window.
 
{: align="center"}
<img src="../../assets/images_tutorials/result_sample_9.png" alt="flux_map_visualization" width="640"/>

# Create a new project
1. Start OpenMebius2 program.
2. Click the ```Browse``` button in the ```Template Model``` field on the bottom left of the window.

{: align="center"}
![browse_template_model](../../assets/images_tutorials/template_model0.png)

3. Navigate to the ```model``` folder in the unzipped ```OpenMebius2``` directory. Click the ```Select Folder``` button to select the template model.

{: align="center"}
<img src="../../assets/images_tutorials/template_model1.png" alt="select_template_model" width="640"/>

4. Click the ```Load``` button to load the template model.

{: align="center"}
<img src="../../assets/images_tutorials/template_model2.png" alt="load_template_model" width="640"/>

5. After loading the template model, click the ```Create project from template model``` button to create a new project.

{: align="center"}
<img src="../../assets/images_tutorials/template_model3.png" alt="new_project_button" width="640"/>

1. In the dialog that appears, enter the project name. Then click the ```OK``` button.

{: align="center"}
<img src="../../assets/images_tutorials/template_model4.png" alt="create_new_project" width="640"/>

7. Select the folder where you want to save the new project and click the ```Select Folder``` button.

{: align="center"}
<img src="../../assets/images_tutorials/template_model5.png" alt="select_new_project_folder" width="640"/>

8. Wait a moment while the new project is being created. The indicator icon on the model will turn green when the process is complete.

{: align="center"}
<img src="../../assets/images_tutorials/template_model6.png" alt="creating_new_project" width="640"/>

8. The new project is now created and loaded. You can start customizing the model, adding experimental data, and performing analysis.

{: align="center"}
<img src="../../assets/images_tutorials/template_model7.png" alt="new_project_loaded" width="640"/>

# Importing template data


# 13C-metabolic flux analysis (13C-MFA)

# Instationary-MFA (INST-MFA)

# Evaluation of confidence intervals

## Grid search method

## Monte-Carlo method

# Label pattern optimization

# Label suggestion
