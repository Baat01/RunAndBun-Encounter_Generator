# Run & Bun - NG+ Encounter Generator

Ce projet est un outil d'injection et de génération de rencontres Pokémon conçu spécifiquement pour les parties de **Pokémon Run & Bun** en **New Game Plus (NG+)**. Il permet de simuler et de générer des rencontres basées sur les tables d'apparition d'une zone tout en respectant une clause stricte de doublons (Dupes) entièrement synchronisée avec la progression globale de vos différentes parties.

## 🛠️ Configuration & Setup

Avant de pouvoir utiliser l'outil en jeu, vous devez configurer vos chemins d'accès locaux et générer votre liste personnalisée de doublons.


### 1. Génération du fichier `dupes.json`

Pour que la clause de doublons fonctionne, le script doit connaître la liste des Pokémon que vous avez déjà capturés lors de vos sessions précédentes.

1. Rendez-vous sur la feuille de calcul (et faites en une copie si ce n'est pas déjà le cas) **Advanced Frag Sheet** disponible à cette adresse : [Advanced Frag Sheet](https://docs.google.com/spreadsheets/d/1qA8Zttt3hKR7pwfvDVw3S7xuNEcPYc8kO_TDyea_L5I/edit?usp=sharing).
2. Renseignez l'ensemble de vos captures de la partie classique dans l'onglet caché nommé **"New Game + Dupes"**.
3. Si vous avez déjà effectué un NG+, inscrivez-les également.
4. Si nécessaire, complétez avec les captures de votre run actuelle en utilisant votre export via le script (Page Run&Bun Nuzlocke Tracker).
5. Allez sur l'onglet caché intitulé **"NG+ Dupes Json Generator"**.
6. Cliquez sur le bouton **"Click Me"** présent sur la page pour générer la structure de données.
7. Copiez l'intégralité du texte généré et remplacez le contenu du fichier `dupes.json` situé dans le sous-dossier `data/` de votre projet.

---

### 2. Gestion avancée des doublons (Optionnel)

Par défaut, l'outil lie l'ensemble des formes régionales au même ID de doublon. Vous pouvez personnaliser ce comportement selon les règles de votre Nuzlocke en modifiant la variable `selectedDupesMode` située à la **ligne 174 du fichier `runner.lua**` :

```lua
-- À la ligne 184 de runner.lua
local selectedDupesMode  = "dupe both" 

```

Vous pouvez remplacer `"dupe both"` par l'une des **3 configurations suivantes** :

* **`"dupe both"`** : La forme de base, la forme régionale ainsi que son évolution partagent la même famille de doublons. Si vous possédez l'une des formes, toutes les autres variantes de l'espèce sont bloquées dans les zones de rencontre.
  *Exemple :* Si vous possédez Growlithe, Growlithe-Hisui et Arcanine-Hisui seront considérés comme des doublons et exclus des futurs tirages.

* **`"same name"`** : Permet de dissocier les nouvelles évolutions exclusives (comme Sneasler ou Overqwil) de l'espèce d'origine si elles ne partagent pas exactement le même nom, tout en bloquant les formes qui ont le même nom de base.
  *Exemple :* Posséder Sneasel de Johto bloquera Sneasel-Hisui, mais vous laissera l'opportunité de capturer Farfurex (Sneasler).

* **`"neither"`** : Toutes les formes régionales et leurs évolutions exclusives sont considérées comme des lignées totalement indépendantes. Capturer une forme d'Alola, de Galar ou d'Hisui ne bloque pas la forme classique.
  *Exemple :* Pour `"Raichu-Alola"`, capturer un Raichu normal ne vous empêchera pas de tomber sur la variante d'Alola.

---

### 3. Synchronisation des chemins locaux (Optionnel / Secours)

> **Note importante :** Le script intègre désormais un système de détection automatique de votre dossier. **Vous n'avez pas besoin de modifier les chemins manuellement par défaut.**
>
> Effectuez la manipulation ci-dessous **UNIQUEMENT** si, lors du lancement du script dans mGBA, vous obtenez l'erreur suivante dans la console :
> `Impossible de détecter le dossier automatiquement` suivie d'un crash `cannot open nil...`.

Si (et seulement si) la détection automatique échoue, ouvrez les fichiers suivants et modifiez la variable `root` pour y renseigner manuellement l'adresse du dossier contenant les lua téléchargés sur votre ordinateur :

#### ! Il est important, comme sur l'exemple, d'utiliser des / entre les dossiers, et non des \ pour le path
❌ H:\Downloads\Run&Bun\NG+ Encounter Generator\
✅ H:/Downloads/Run&Bun/NG+ Encounter Generator/

* **Dans `runner.lua`** (Ligne 44) :
```lua
local root = "H:/Downloads/Run&Bun/NG+ Encounter Generator/"

```

* **Dans `Run&Bun Tracking Script.lua`** (Ligne 8232) :

```lua
local root = "H:/Downloads/Run&Bun/NG+ Encounter Generator/"

```

---

## 🎮 Utilisation en jeu

Une fois la configuration terminée, lancez votre émulateur (mGBA 0.10+ recommandé), ouvrez les outils de script et chargez le fichier `Run&Bun Tracking Script.lua`.

Deux fonctions majeures deviennent alors disponibles dans la console pour faire vos zones :

#### ! Pour ces deux fonctions, le pokémon n'est pas généré de 0, il vous faut avoir déjà un pokémon dans le slot sur lequel vous l'utilisez

### Générer une rencontre dans l'Équipe (Party)

Exécutez la commande suivante dans la console de script :

```lua
DupedEncounterToParty(zoneNameInput, slotTarget, repelManip)

```

* **`zoneNameInput`** *(string)* : Le nom de la table d'apparition à cibler (recherche permissive par mot-clé, voir la liste en fin de fichier).
* **`slotTarget`** *(number)* : L'emplacement dans votre équipe active où injecter le Pokémon (1 à 6).
* **`repelManip`** *(boolean)* : Mettez `true` si vous souhaitez activer la repel manip (force l'obtention du niveau maximum de la zone), sinon mettez `false`. Ne pas mettre d'argument n'activera pas la repel manip (voir l'exemple PC).

**Exemple :** `DupedEncounterToParty("Meteor Falls 1F1 Surf", 2, true)`

### Générer une rencontre dans le PC

Exécutez la commande suivante pour envoyer directement le Pokémon dans vos boîtes PC :

```lua
DupedEncounterToPC(zoneNameInput, pcSlotIndex, repelManip)

```

* **`pcSlotIndex`** *(number)* : L'index de la case du PC cible (0 pour le premier emplacement, 1 pour le second, etc.).

**Exemple :** `DupedEncounterToPC("Littleroot Town Fishing", 0)`

> **Note sur les fonctionnalités automatiques :**
> * **Magnet Pull & Static :** Si vous ciblez un emplacement autre que le premier slot, le script vérifie automatiquement le talent du Pokémon en tête de votre équipe. S'il possède Magnet Pull ou Static, le pool de la zone se restreindra (avec 50% de chances) aux types Acier ou Électrique.
> * **Synchro :** Si vous ciblez un emplacement autre que le premier slot, le script vérifie automatiquement le talent du Pokémon en tête de votre équipe. S'il possède Synchro, le pokémon obtenu aura une chance sur deux d'avoir la même nature que celui-ci.

La liste exacte de toutes les valeurs valides utilisables pour le paramètre `zoneNameInput` est disponible en bas du readme

---

# English Version 

# Run & Bun - NG+ Encounter Generator

This project is an injection and encounter generation tool designed specifically for **Pokémon Run & Bun** in **New Game Plus (NG+)** mode. It simulates and generates random encounters based on a zone's encounter table while enforcing a strict dupe clause synchronized with your global cross-save progression.

## 🛠️ Configuration & Setup

Before running the tool in-game, you must configure your local folder paths and generate your personalized dupes file.

### 1. Generating the `dupes.json` File

For the dupe clause to function correctly, the script requires the list of Pokémon you have already caught in your previous playthroughs.

1. Open and make a copy of the **Advanced Frag Sheet** tracking spreadsheet here: [Advanced Frag Sheet](https://docs.google.com/spreadsheets/d/1qA8Zttt3hKR7pwfvDVw3S7xuNEcPYc8kO_TDyea_L5I/edit?usp=sharing).
2. Input all of your caught encounters from your classic run into the hidden tab named **"New Game + Dupes"**.
3. If you have already finished NG+, add them too.
4. If necessary, complete it with the current run's encounters using your Box export from the script (Tab Run&Bun Nuzlocke Tracker).
5. Go to the hidden tab called **"NG+ Dupes Json Generator"**.
6. Click the **"Click Me"** button to format the dataset.
7. Copy the entire generated text structure and overwrite the content of the **`dupes.json`** file inside the `data/` subfolder (or root folder depending on your setup).

---

### 2. Advanced Dupes Configuration (Optional)

By default, the generator locks regional forms under the same dupe family as their base form. You can adjust this to your custom Nuzlocke rules by changing the `selectedDupesMode` value at **line 174 inside `runner.lua**`:

```lua
-- On line 184 of runner.lua
local selectedDupesMode  = "dupe both" 

```

You can set it to one of these **3 valid choices**:

* **`"dupe both"`**: Base form, regional form, and its evolution all share the exact same dupe family ID. Catching any version locks out the entire species family from future rolls.
  *Example :* For Growlithe, owning a regular Growlithe automatically treats Growlithe-Hisui and Arcanine-Hisui as dupes.


* **`"same name"`**: Dissociates brand new exclusive evolutions (like Sneasler or Overqwil) that do not explicitly share the original species name, while keeping same-named regional forms locked.
  *Example :* Owning a vanilla Sneasel will block Sneasel-Hisui, but leaves Sneasler open to be rolled.


* **`"neither"`**: Every regional variant and variant evolution line is treated completely independently from its vanilla counterpart.
  *Example :* Catching a standard Kanto Raichu won't prevent the Alolan variant from appearing.

---
### 3. Synchronizing Local Directory Paths (Optional / Fallback)

> **Important Note:** The script now includes an automatic folder path detection system. **You do not need to manually edit paths by default.**
> Follow the steps below **ONLY** if you encounter the following error message inside the mGBA script console when launching the tool:
> `Impossible de détecter le dossier automatiquement` followed by a `cannot open nil...` crash.

If (and only if) the auto-detection fails, open the following files and manually edit the `root` variable to match the absolute directory path of the directory you've installed on your computer:

#### ! It is a must, like the example, to use / between folder instead of \ for the path

❌ H:\Downloads\Run&Bun\NG+ Encounter Generator
✅ H:/Downloads/Run&Bun/NG+ Encounter Generator/

* **Inside `runner.lua`** (Line 44):

```lua
local root = "H:/Downloads/Run&Bun/NG+ Encounter Generator/"

```

* **Inside `Run&Bun Tracking Script.lua`** (Line 8232):

```lua
local root = "H:/Downloads/Run&Bun/NG+ Encounter Generator/"

```
---

## 🎮 In-Game Usage

Once configuration is complete, boot up your emulator (mGBA 0.10+ recommended), open the scripting tools, and load the **`Run&Bun Tracking Script.lua`** file.

Two main functions will become available in your console to trigger rolls:

#### ! For both of the functions, the pokemon isn't generated but replaced, so you already need to have a pokemon on the slot you're using it on

### Inject an Encounter into your Party

Execute this command in the scripting console:

```lua
DupedEncounterToParty(zoneNameInput, slotTarget, repelManip)

```

* **`zoneNameInput`** *(string)*: The name of the encounter pool to target (supports permissive keyword search, see full list at the bottom).
* **`slotTarget`** *(number)*: The active party slot to inject the Pokémon into (1 to 6).
* **`repelManip`** *(boolean)*: Pass `true` if you want to force the maximum available level of the zone (Repel Manip simulator), otherwise pass `false`. It's an optionnal parameter, not putting it won't activate the repel manip (see PC example).

**Example:** `DupedEncounterToParty("Meteor Falls 1F1 Surf", 2, true)`

### Inject an Encounter into your PC Boxes

Execute this command to send the rolled Pokémon directly to your PC storage:

```lua
DupedEncounterToPC(zoneNameInput, pcSlotIndex, repelManip)

```

* **`pcSlotIndex`** *(number)*: The exact index of the target PC slot (0 for the very first case, 1 for the second, etc.).

**Example:** `DupedEncounterToPC("Littleroot Town Fishing", 0)`


> **About automatic function :**
> * **Magnet Pull & Static :** If you chose a slot other than the first one, the script will automatically check the ability of your lead. If he has Magnet Pull or Static, it'll get a chance to proc, and restrain the pool to Steel/Electric types.
> * **Synchronize :** If you chose a slot other than the first one, the script will automatically check the ability of your lead. If he has Synchronize, it'll get a chance to proc, and have the nature of the synchronize mon.

---

## 🗺️ Available Encounter Tables (Sorted Alphabetically)

Here is the full list of valid string values for the `zoneNameInput` parameter:

* "Abandoned Ship B1F Rooms Fishing"
* "Abandoned Ship B1F Rooms Surf"
* "Altering Cave Land"
* "Aqua Hideout B1F Land"
* "Desert Underpass Land"
* "Dewford Town Fishing"
* "Dewford Town Land"
* "Dewford Town Surf"
* "Ever Grande City Land"
* "Fallarbor Town Land"
* "Fiery Path Land"
* "Fortree City Fishing"
* "Fortree City Land"
* "Fortree City Surf"
* "Granite Cave 1F Land"
* "Granite Cave B1F Land"
* "Granite Cave B2F Land"
* "Granite Cave B2F Rock Smash"
* "Jagged Pass Land"
* "Lavaridge Town Gift"
* "Lilycove City Land"
* "Littleroot Town Fishing"
* "Littleroot Town Surf"
* "Magma Hideout Room 1 Land"
* "Magma Hideout Room 2-4 Land"
* "Magma Hideout Room 5 Land"
* "Magma Hideout Room 6-7 Land"
* "Meteor Falls 1F1 Fishing"
* "Meteor Falls 1F1 Land"
* "Meteor Falls 1F1 Surf"
* "Mirage Tower 1F Land"
* "Mirage Tower 2F Land"
* "Mirage Tower 3F Land"
* "Mirage Tower 4F Land"
* "Mossdeep City Land"
* "Mt. Chimney Land"
* "Mt. Pyre 1F-2F Fishing"
* "Mt. Pyre 3F-4F Fishing"
* "Mt. Pyre 5F-6F Fishing"
* "Mt. Pyre (Exterior) Fishing"
* "Mt. Pyre (Summit) Fishing"
* "New Mauville (Inside) Land"
* "New Mauville (Outside) Land"
* "New Mauville Gift"
* "Oldale Town Land"
* "Petalburg City Fishing"
* "Petalburg City Surf"
* "Petalburg Woods Land"
* "Route 101 Land"
* "Route 102 Fishing"
* "Route 102 Land"
* "Route 102 Surf"
* "Route 103 Fishing"
* "Route 103 Land"
* "Route 103 Surf"
* "Route 104 Fishing"
* "Route 104 Land"
* "Route 104 Surf"
* "Route 105 Fishing"
* "Route 105 Land"
* "Route 105 Surf"
* "Route 106 Fishing"
* "Route 106 Surf"
* "Route 107 Fishing"
* "Route 107 Surf"
* "Route 108 Fishing"
* "Route 108 Surf"
* "Route 109 Fishing"
* "Route 109 Surf"
* "Route 110 Fishing"
* "Route 110 Land"
* "Route 110 Surf"
* "Route 111 Fishing"
* "Route 111 Land"
* "Route 111 Rock Smash"
* "Route 111 Surf"
* "Route 112 Land"
* "Route 113 Land"
* "Route 114 Fishing"
* "Route 114 Land"
* "Route 114 Rock Smash"
* "Route 114 Surf"
* "Route 115 Fishing"
* "Route 115 Surf"
* "Route 116 Land"
* "Route 117 Fishing"
* "Route 117 Land"
* "Route 117 Surf"
* "Route 118 Fishing"
* "Route 118 Land"
* "Route 118 Surf"
* "Route 119 Fishing"
* "Route 119 Gift"
* "Route 119 Land"
* "Route 119 Surf"
* "Route 120 Fishing"
* "Route 120 Land"
* "Route 120 Surf"
* "Route 121 Fishing"
* "Route 121 Land"
* "Route 121 Surf"
* "Route 122 Land"
* "Route 123 Land"
* "Route 124 Land"
* "Route 125 Land"
* "Route 126 Land"
* "Route 127 Land"
* "Route 128 Land"
* "Route 129 Land"
* "Route 130 Land"
* "Route 131 Land"
* "Route 134 Fishing"
* "Route 134 Surf"
* "Safari Zone (North) Land"
* "Safari Zone (Northwest) Land"
* "Safari Zone (South) Fishing"
* "Safari Zone (South) Land"
* "Safari Zone (South) Surf"
* "Safari Zone (Southwest) Land"
* "Scorched Slab Fishing"
* "Scorched Slab Land"
* "Scorched Slab Surf"
* "Seafloor Cavern Entrance Land"
* "Seafloor Cavern Rooms 1-5 Land"
* "Shoal Cave (Entrance/Inner) Land"
* "Shoal Cave (Ice Room) Fishing"
* "Shoal Cave (Ice Room) Land"
* "Shoal Cave (Ice Room) Surf"
* "Shoal Cave (Other Rooms) Land"
* "Slateport City Fishing"
* "Slateport City Surf"
* "Sootopolis City Land"
* "Steven's Room Land"
* "Sky Pillar 1F and 3F Land"
* "Sky Pillar 5F Land"
* "Verdanturf Town Land"
* "Victory Road 1F Land"
* "Victory Road B1F Fishing"
* "Victory Road B1F Land"
* "Victory Road B1F Rock Smash"
* "Victory Road B1F Surf"
* "Victory Road B2F Land"
* "Victory Road B2F Rock Smash"
