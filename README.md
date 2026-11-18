# Boulder Dash – Processing (Java)

Reproduction du jeu classique **Boulder Dash**, réalisée en équipe au semestre 4 de ma formation en informatique, avec **Processing** (langage basé sur Java) et en **programmation orientée objet**.

Le joueur creuse la terre pour ramasser des diamants, en évitant les rochers qui tombent et les ennemis. Quand il a assez de diamants, la sortie s'ouvre et il passe au niveau suivant.

<!-- Ajoute ici une capture d'écran du jeu : glisse l'image "capture.png" dans le dépôt, puis garde la ligne ci-dessous -->
![Capture du jeu](capture.png)

## Fonctionnalités

- **6 niveaux**, dont des niveaux bonus, chargés depuis des fichiers texte
- **Mode 2 joueurs** sur le même clavier
- **Éditeur de niveaux** : dessiner un niveau à la souris, puis le sauvegarder et le recharger
- **Top 5 des scores**, enregistré avec le pseudo du joueur
- **Moteur physique** : chute des rochers et des diamants
- **Ennemis** qui se déplacent, et **mur magique**
- Système de **vies**, de **score** et de **temps limité**
- **Sons** générés directement en Java
- **Pause** et menu principal animé

## Commandes

| Action | Touche |
|---|---|
| Se déplacer (solo) | Flèches ou Z Q S D |
| Joueur 1 (mode 2 joueurs) | Z Q S D |
| Joueur 2 (mode 2 joueurs) | Flèches |
| Pause | P |
| Couper / remettre le son | M |
| Retour au menu | Échap |
| Éditeur : sauvegarder / charger / réinitialiser | S / L / R |

## Lancer le jeu

1. Installer [Processing](https://processing.org/download) (version 4).
2. Télécharger ce dépôt (bouton **Code → Download ZIP**) et le décompresser.
3. Ouvrir le fichier `BoulderDashfinal/BoulderDashfinal.pde` avec Processing.
4. Cliquer sur **Run** (▶).

## Organisation du code

Chaque élément du jeu est une **classe** qui hérite de la classe abstraite `Element` :

- `Joueur`, `Ennemi`, `Rocher`, `Diamant`, `Terre`, `Mur`, `MurMagique`, `Sortie` : les éléments de la grille
- `GestionnaireJeu` : déroulement de la partie (niveaux, score, vies, temps, mode 2 joueurs)
- `MoteurPhysique` : chute des objets et collisions
- `Niveau` : chargement des niveaux depuis le dossier `data`
- `Editeur`, `Menu`, `Top5`, `Son` : éditeur, menu, meilleurs scores et sons

## Équipe

Projet réalisé en groupe dans le cadre de ma formation.
- **Mariem El Babidi** : [décris ici ce que tu as fait, par exemple : l'éditeur de niveaux, le moteur physique…]
- [Prénoms des autres membres de l'équipe]
