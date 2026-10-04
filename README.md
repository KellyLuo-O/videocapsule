# Videocapsule project, cours de master UEC13

Projet de conception d'un système embarqué pour le traitement d'images issues d'une **vidéo-capsule**, réalisé dans le cadre du master UEC13.

Le projet consiste à intégrer un prétraitement matériel permettant de calculer un **indice colorimétrique** à partir des composantes RGB d'une image, puis à afficher graphiquement cet indice sur une sortie HDMI.

Le système est développé autour d'une **carte Terasic DE10-Nano**, équipée d'un FPGA Intel/Altera, d'un processeur softcore **Nios II** et d'un système **SoPC basé sur Avalon**.

> **Remarque :** le projet utilise une DE10-Nano

---

## 🎯 Objectifs

L'objectif principal est de réaliser une chaîne de traitement embarquée capable de :

1. recevoir les composantes RGB d'une image ;
2. effectuer une accumulation matérielle des valeurs RGB ;
3. calculer la moyenne de chaque composante ;
4. calculer un indice colorimétrique, notamment l'indice **R/G** ;
5. transmettre les résultats au processeur Nios II ;
6. générer une courbe représentant l'évolution de l'indice ;
7. afficher cette courbe sur une sortie HDMI.

L'intérêt de cette architecture est de réaliser une partie du prétraitement directement dans le FPGA afin de limiter les traitements effectués par le processeur.

---

## 🏗️ Architecture générale

Le système est organisé autour de plusieurs blocs matériels et logiciels :

```text
                 ┌─────────────────────────┐
                 │       Entrées RGB       │
                 │     Image / Pixels       │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │     IP Colorimétrie     │
                 │                         │
                 │  Accumulation RGB       │
                 │  Moyenne R / G / B      │
                 │  Indice colorimétrique  │
                 └────────────┬────────────┘
                              │
                       Avalon-MM
                              │
                              ▼
                 ┌─────────────────────────┐
                 │        Nios II          │
                 │                         │
                 │ Lecture des moyennes    │
                 │ Calcul de l'indice R/G  │
                 │ Génération de la courbe │
                 └────────────┬────────────┘
                              │
                         Avalon-MM
                              │
                              ▼
                 ┌─────────────────────────┐
                 │    RAM double port      │
                 │     d'affichage         │
                 └────────────┬────────────┘
                              │
                       Horloge pixel
                              │
                              ▼
                 ┌─────────────────────────┐
                 │    HDMI Controller      │
                 │                         │
                 │ HS / VS / DE            │
                 │ Génération des pixels   │
                 └────────────┬────────────┘
                              │
                              ▼
                         Sortie HDMI
```

---

## 📁 Arborescence

L'arborescence actuelle du dépôt est organisée comme suit :

```text
videocapsule/
│
├── .qsys_edit/
│
├── docs/
│
├── i2c/
│
├── pll/
│
├── pll2/
│
├── sim/
│
├── sopc/
│
├── I2C_HDMI_Config.bsf
├── PLLJ_PLLSPE_INFO.txt
├── c5_pin_model_dump.txt
├── cr_ie_info.json
│
├── colorimetrie.vhd
│
├── hdmi_controler.vhd
├── hdmi_controler.bsf
│
├── rgb_3_to_8.vhd
├── rgb_3_to_8.bsf
│
├── ram_affichage.vhd
├── ram_affichage.bsf
├── ram_affichage.cmp
├── ram_affichage.qip
│
├── count.vhd
├── count.bsf
├── count.cmp
├── count.qip
│
├── videocapsule.bdf
├── videocapsule.qpf
├── videocapsule.qsf
│
├── niosii.sopcinfo
│
├── .gitignore
└── README.md
```

Le dépôt contient également les fichiers générés par Quartus/IP Catalog ainsi que les différents composants nécessaires à la construction du système SoPC.

---

## 🔧 Matériel et environnement

### Carte cible

* **Terasic DE10-Nano**
* FPGA Intel/Altera
* Sortie HDMI
* Processeur softcore Nios II

Le choix de la DE10-Nano implique l'utilisation d'un contrôleur **HDMI** plutôt qu'un contrôleur VGA.

---

## 🧩 Principaux composants matériels

### `colorimetrie.vhd`

L'IP `colorimetrie` constitue le cœur du prétraitement.

Elle est connectée au bus **Avalon Memory-Mapped** du Nios II et possède notamment les interfaces :

```text
address
writedata
readdata
write
read
chipselect
reset
clk
```

ainsi que les entrées liées aux pixels :

```text
R
G
B
clk_pixel
synchro_trame
```

L'IP accumule les composantes RGB des pixels reçus et permet ensuite au Nios II de lire leurs valeurs moyennes.

Le fonctionnement est basé sur deux domaines d'horloge :

* `clk` : horloge système / interface Avalon ;
* `clk_pixel` : horloge associée aux pixels.

Lorsqu'une nouvelle trame commence, `synchro_trame` permet de remettre à zéro les sommes et compteurs.

Pour chaque pixel valide :

```text
sum_r += R
sum_g += G
sum_b += B

nb_value_r++
nb_value_g++
nb_value_b++
```

Les moyennes sont ensuite calculées par :

```text
R_moy = sum_r / nb_value_r
G_moy = sum_g / nb_value_g
B_moy = sum_b / nb_value_b
```

---

### `hdmi_controler.vhd`

Le contrôleur HDMI génère les signaux nécessaires à l'affichage :

```text
HS
VS
DE
pixel_enable
pixel_address
```

Il utilise des compteurs horizontaux et verticaux pour parcourir l'image pixel par pixel.

Le contrôleur utilise une résolution de travail définie dans ses génériques et génère l'adresse correspondante dans la mémoire vidéo.

---

### `rgb_3_to_8.vhd`

La mémoire vidéo utilise **9 bits par pixel** :

```text
RRR GGG BBB
```

soit :

* 3 bits pour R ;
* 3 bits pour G ;
* 3 bits pour B.

Le HDMI utilise quant à lui 8 bits par composante.

Le module `rgb_3_to_8` réalise donc l'expansion :

```text
RGB 3 bits/component
        │
        ▼
RGB 8 bits/component
```

Cela permet de réduire fortement la quantité de mémoire nécessaire pour stocker l'image.

---

### `ram_affichage`

Une RAM double port est utilisée pour l'affichage.

Les deux ports ont des rôles différents :

```text
Port écriture
    │
    └── Nios II / IP colorimétrie

Port lecture
    │
    └── Contrôleur HDMI
```

Cette architecture permet au processeur de modifier l'image pendant que le contrôleur HDMI lit les pixels destinés à l'affichage.

---

## 🖥️ Génération de la courbe

Le Nios II lit les moyennes R et G depuis l'IP `colorimetrie` et calcule l'indice :

```c
indice_rg = r_value / g_value;
```

La valeur obtenue est ensuite transformée en coordonnée verticale :

```c
courbe_rg[courbe_index] = ORIGIN_AXE_Y - 10 * indice_rg;
```

La courbe est progressivement dessinée dans la RAM vidéo.

Le programme utilise plusieurs couleurs pour différencier les éléments de l'affichage :

```text
WHITE  → fond / effacement
BLACK  → repère et axes
RED    → ancienne position
BLUE   → nouvelle valeur
GREEN  → disponible
```

---

## 📊 Affichage

L'affichage contient un repère cartésien et une courbe représentant l'évolution de l'indice R/G.

Le programme définit notamment :

```c
#define H_RES 640
#define V_RES 480

#define DEBUT_AXE_X 50
#define FIN_AXE_X 600
#define ORIGIN_AXE_Y 400
```

La courbe est donc dessinée progressivement sur la zone d'affichage.

Lorsque l'extrémité de l'axe horizontal est atteinte, l'index revient au début :

```text
50 → 51 → 52 → ... → 600
                      │
                      └── retour à 50
```

---

## 💾 Communication avec l'IP

Les registres utilisés par le Nios II sont définis dans `display.h` :

```c
#define READ_R             0x1
#define READ_G             0x2
#define READ_B             0x3
#define WRITE_RGB          0x4
#define WRITE_PIXEL_ADDR   0x5
#define WRITE_PIXEL_VALUE  0x6
#define WRITE_RAM_WE       0x7
```

Le Nios II utilise les macros `IORD` et `IOWR` pour communiquer avec l'IP.

Exemple de lecture :

```c
r_value = IORD(COLORIMETRIE_0_BASE, READ_R);
g_value = IORD(COLORIMETRIE_0_BASE, READ_G);
```

Exemple d'écriture d'un pixel :

```c
IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x0);
IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_VALUE, color);
IOWR(COLORIMETRIE_0_BASE, WRITE_PIXEL_ADDR, address);
IOWR(COLORIMETRIE_0_BASE, WRITE_RAM_WE, 0x1);
```

---

## 🧠 SoPC / Nios II

Le système embarqué repose sur un **SoPC** intégrant un processeur Nios II.

Le système permet au processeur de communiquer avec les périphériques matériels grâce au bus Avalon Memory-Mapped.

La conception matérielle est représentée par :

```text
videocapsule.bdf
```

et la configuration Quartus par :

```text
videocapsule.qpf
videocapsule.qsf
```

Le fichier :

```text
niosii.sopcinfo
```

contient les informations du système SoPC nécessaires à l'environnement logiciel Nios II.

---

## 🧪 Simulation

Le dossier :

```text
sim/
```

contient les éléments associés à la simulation du projet.

La simulation permet notamment de vérifier le comportement de l'IP de colorimétrie avant son intégration complète dans le système.

Les principaux comportements vérifiés sont :

* remise à zéro lors d'une nouvelle trame ;
* accumulation des valeurs RGB ;
* comptage des pixels ;
* calcul des moyennes ;
* lecture des valeurs via l'interface Avalon.

---

## 🚀 Compilation et programmation

Le projet est destiné à être utilisé avec **Intel Quartus Prime** et les outils Nios II.

### 1. Ouvrir le projet

Ouvrir :

```text
videocapsule.qpf
```

avec Quartus Prime.

### 2. Vérifier le système matériel

Le schéma principal se trouve dans :

```text
videocapsule.bdf
```

Les IP et composants nécessaires sont ensuite intégrés au système SoPC.

### 3. Compiler

Lancer la compilation complète du projet depuis Quartus.

Vérifier notamment :

* les connexions des horloges ;
* les connexions HDMI ;
* les pins de la DE10-Nano ;
* l'intégration du Nios II ;
* l'IP `colorimetrie` ;
* la RAM d'affichage.

### 4. Programmer la carte

Après compilation, programmer le FPGA de la DE10-Nano avec le fichier `.sof` généré par Quartus.

### 5. Programmer le Nios II

Générer le BSP et compiler l'application Nios II avec les outils Intel/Altera correspondants.

Le programme principal communique alors avec :

```text
COLORIMETRIE_0_BASE
```

pour récupérer les valeurs colorimétriques et contrôler l'affichage.

---

## 🔬 Démonstrateur

Pour tester le fonctionnement de l'indice colorimétrique, les entrées RGB peuvent être fixées à différentes valeurs.

Dans le démonstrateur décrit dans le projet :

### SW2 = 0

```text
R = 10
G = 1
B = 10

R/G = 10
```

### SW2 = 1

```text
R = 10
G = 10
B = 10

R/G = 1
```

Cette configuration permet de vérifier visuellement l'évolution de la courbe HDMI en fonction de l'indice calculé.

---

## 📐 Contraintes mémoire

Une image RGB classique en 640×480 avec 24 bits par pixel nécessite :

```text
640 × 480 × 24
= 7 372 800 bits
```

Cette quantité dépasse la mémoire disponible envisagée pour l'affichage.

Le projet utilise donc un stockage de :

```text
9 bits / pixel
```

soit :

```text
640 × 480 × 9
= 2 764 800 bits
```

avec 3 bits par composante RGB.

Le module `rgb_3_to_8.vhd` reconstruit ensuite les composantes 8 bits nécessaires à l'affichage HDMI.

---

## 📚 Organisation du code logiciel

La partie logicielle principale est organisée autour de trois fonctions :

### Lecture des valeurs colorimétriques

```c
IORD(COLORIMETRIE_0_BASE, READ_R);
IORD(COLORIMETRIE_0_BASE, READ_G);
IORD(COLORIMETRIE_0_BASE, READ_B);
```

### Calcul de l'indice

```c
indice_rg = r_value / g_value;
```

### Affichage

Les fonctions d'affichage permettent de :

```text
display_pixel()
display_clean()
display_repere()
```

et de modifier directement les pixels de la RAM vidéo.

---

## 🛠️ Technologies utilisées

* **VHDL**
* **C**
* **Intel/Altera Quartus Prime**
* **Nios II**
* **Avalon Memory-Mapped**
* **SoPC Builder / Platform Designer**
* **FPGA**
* **DE10-Nano**
* **HDMI**
* **RAM double port**

---

## 📌 État du projet

Le dépôt contient actuellement les principaux éléments nécessaires au démonstrateur :

* [x] SoPC avec Nios II
* [x] IP de calcul colorimétrique
* [x] Communication Avalon
* [x] Calcul des moyennes RGB
* [x] Contrôleur HDMI
* [x] RAM d'affichage
* [x] Conversion RGB 3 bits → 8 bits
* [x] Génération d'un repère graphique
* [x] Calcul de l'indice R/G
* [x] Affichage de la courbe

---

## 📄 Documentation

La documentation du projet et les ressources complémentaires sont disponibles dans :

```text
docs/
```

Le rapport de conception présente notamment la conception du SoPC/Nios II, l'IP de colorimétrie, le contrôleur HDMI et le démonstrateur final.

