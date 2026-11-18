class MoteurPhysique {
  GestionnaireJeu jeu;

  MoteurPhysique(GestionnaireJeu jeu) {
    this.jeu = jeu;
  }

  void actualiser(Niveau niveau) {
    int cols = niveau.cols;
    int rows = niveau.rows;
    // Empêche qu'un élément soit déplacé deux fois dans le même tick
    boolean[][] aBoge = new boolean[cols][rows];

    // Parcours de bas en haut pour que la gravité cascade correctement en une seule passe
    for (int y = rows - 2; y >= 0; y--) {
      for (int x = 1; x < cols - 1; x++) {
        if (aBoge[x][y]) continue;

        Element e = niveau.grille[x][y];
        if (!(e instanceof Rocher) && !(e instanceof Diamant)) continue;

        boolean enChuteActuellement = false;
        if (e instanceof Rocher)  enChuteActuellement = ((Rocher)e).enChute;
        if (e instanceof Diamant) enChuteActuellement = ((Diamant)e).enChute;

        Element enDessous = niveau.grille[x][y + 1];

        if (enDessous == null) {
          // Case vide en dessous : chute libre
          niveau.deplacerElement(e, x, y + 1);
          aBoge[x][y + 1] = true;
          setChute(e, true);

        } else if (enDessous instanceof Joueur) {
          // Écrase le joueur uniquement s'il était déjà en chute et n'est pas invulnérable
          Joueur jEcrase = (Joueur) enDessous;
          if (enChuteActuellement && millis() >= jEcrase.bloqueJusquA) {
            jEcrase.vivant = false;
            niveau.deplacerElement(e, x, y + 1);
            son.rocherTombe();
            aBoge[x][y + 1] = true;
            setChute(e, false);
          } else {
            setChute(e, false);
          }

        } else if (enDessous instanceof Ennemi) {
          // Tue l'ennemi uniquement si l'élément était en chute
          if (enChuteActuellement) {
            niveau.ennemis.remove((Ennemi) enDessous);
            niveau.deplacerElement(e, x, y + 1);
            son.rocherTombe();
            jeu.ajouterBonus(100);
            aBoge[x][y + 1] = true;
            setChute(e, false);
          } else {
            setChute(e, false);
          }

        } else if (enDessous instanceof MurMagique) {
          // Un rocher en chute traversant un mur magique devient un diamant sous le mur
          if (enChuteActuellement && e instanceof Rocher) {
            int bx = x, by = y + 2;
            Element sousMur = by < rows ? niveau.getElement(bx, by) : new Mur(bx, by);
            if (sousMur == null || sousMur instanceof Terre) {
              niveau.grille[x][y] = null;
              niveau.grille[bx][by] = null;
              Diamant d = new Diamant(bx, by);
              d.enChute = true;
              niveau.grille[bx][by] = d;
              aBoge[bx][by] = true;
              son.rocherTombe();
            }
            setChute(e, false);
          } else {
            setChute(e, false);
          }

        } else if (enDessous instanceof Rocher || enDessous instanceof Diamant || enDessous instanceof Mur) {
          setChute(e, false);
          // Glissement latéral : si posé sur un rocher ou diamant arrondi, glisse d'un côté
          if (enDessous instanceof Rocher || enDessous instanceof Diamant) {
            if (niveau.getElement(x-1, y) == null && niveau.getElement(x-1, y+1) == null) {
              niveau.deplacerElement(e, x-1, y);
              aBoge[x-1][y] = true;
            } else if (niveau.getElement(x+1, y) == null && niveau.getElement(x+1, y+1) == null) {
              niveau.deplacerElement(e, x+1, y);
              aBoge[x+1][y] = true;
            }
          }

        } else {
          setChute(e, false);
        }
      }
    }

    for (int i = niveau.ennemis.size() - 1; i >= 0; i--) {
      niveau.ennemis.get(i).actualiser(niveau);
    }
  }

  void setChute(Element e, boolean chute) {
    if (e instanceof Rocher)  ((Rocher)e).enChute  = chute;
    if (e instanceof Diamant) ((Diamant)e).enChute = chute;
  }
}
