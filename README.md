# TurtTowers

**Senior Computer Science Capstone Project**

**Authors:** [Ryan Madensky](mailto:madensrp@gmail.com), [Keegan Dunn](mailto:keegan.dunn@ocvts.org), [Jason Wang](mailto:jason.wang@ocvts.org)

<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/7d41cd44-b113-4072-9db4-ed7274115de5" />


## Project Overview

TurtTowers is an interactive hybrid tower defense game developed to satisfy the requirements of the Senior Capstone. The project combines strategic gameplay with environmental education, aiming to raise awareness regarding marine ecosystem degradation and ocean pollution.

Players are tasked with defending a central objective, the "Mother Shell," from waves of antagonistic pollutants (plastics, gases, and hazardous waste). The game utilizes a core loop of strategic resource management and tower placement, leveraging a custom economy to upgrade defenses and unlock abilities.

## Gameplay Mechanics

### Core Loop
The gameplay focuses on a classic tower defense structure where enemies follow fixed paths toward a central target.
* **Objective:** Defend the "Mother Shell." The game ends in a loss if the Mother Shell's health reaches zero.
* **Enemies:** Waves consist of ground and airborne troops modeled after real-world pollutants.
* **Economy:** Players collect "Shellings" (in-game currency) from defeated enemies to fund tower construction and upgrades.

### Defense Systems
The game features a variety of turtle-themed defense towers, utilizing distinct attack behaviors:
* **Projectile Towers:** Single-target damage.
* **Area-of-Effect (AOE) Towers:** Crowd control for high-density waves.
* **Defensive Towers:** Shield generation and health mitigation.

### Unique Encounters
The game includes planned boss encounters to challenge player strategies.
* **Boss Concept:** "Cortex the Softshell" — A prominent boss character designed to represent the effects of ocean acidification. The character design reflects shell loss ("cortex" is Latin for shell/bark) caused by environmental corruption.

## Technical Architecture

The application is built using the Unity Engine with C# as the primary programming language. The object scripts will be coded using the JetBrains Rider IDE. The architecture prioritizes modularity and performance optimization to ensure scalability.

### Data Management
* **ScriptableObjects:** All game data (enemy stats, tower attributes, wave configurations) is modularized using Unity's ScriptableObject architecture. This decouples data from logic, allowing designers to balance gameplay without modifying the codebase.

### Performance Optimization
* **Object Pooling:** To maintain a high framerate during intensive waves, the project implements object pooling for all repetitive entities, including enemies, projectiles, and visual effect particles.

## Technology Stack

* **Engine:** Unity
* **Language:** C#
* **Integrated Development Environment (IDE):** JetBrains Rider
* **Version Control:** Git / GitHub
* **Deployment:** Steam

This project is created for academic purposes.
