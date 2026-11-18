class Ennemi extends Element {
  // Direction horizontale : +1 = droite, -1 = gauche
  int dx = 1;

  Ennemi(int x, int y) {
    super(x, y);
  }

  void actualiser(Niveau niveau) {
    int nx = x + dx;
    Element cible = niveau.getElement(nx, y);

    if (cible instanceof Joueur) {
      Joueur j = (Joueur) cible;
      if (millis() >= j.bloqueJusquA) j.vivant = false;
      return;
    }

    if (cible == null || cible instanceof Terre) {
      niveau.deplacerElement(this, nx, y);
    } else {
      // Obstacle rencontré : demi-tour immédiat
      dx = -dx;
      nx = x + dx;
      cible = niveau.getElement(nx, y);
      if (cible instanceof Joueur) {
        Joueur j = (Joueur) cible;
        if (millis() >= j.bloqueJusquA) j.vivant = false;
        return;
      }
      if (cible == null || cible instanceof Terre) {
        niveau.deplacerElement(this, nx, y);
      }
    }

    // Vérification de collision après déplacement (cas où un joueur marche sur l'ennemi)
    if (niveau.joueur != null && niveau.joueur.vivant) {
      if (niveau.joueur.x == x && niveau.joueur.y == y) {
        if (millis() >= niveau.joueur.bloqueJusquA) niveau.joueur.vivant = false;
      }
    }
    if (niveau.joueur2 != null && niveau.joueur2.vivant) {
      if (niveau.joueur2.x == x && niveau.joueur2.y == y) {
        if (millis() >= niveau.joueur2.bloqueJusquA) niveau.joueur2.vivant = false;
      }
    }
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;

    fill(30);
    rect(px, py, TAILLE_TUILE, TAILLE_TUILE);

    fill(210, 40, 40);
    ellipseMode(CORNER);
    ellipse(px + 4, py + 6, TAILLE_TUILE - 8, TAILLE_TUILE - 12);

    fill(255);
    ellipse(px + 8,  py + 9, 9, 9);
    ellipse(px + 23, py + 9, 9, 9);

    // Les pupilles se décalent selon la direction de déplacement
    int offset = dx > 0 ? 2 : -2;
    fill(0);
    ellipse(px + 11 + offset, py + 12, 5, 5);
    ellipse(px + 26 + offset, py + 12, 5, 5);

    fill(160, 20, 20);
    rect(px + 8,  py + 28, 5, 8);
    rect(px + 27, py + 28, 5, 8);
  }
}
