class Joueur extends Element {
  boolean vivant = true;
  int numero;
  int startX, startY;
  int bloqueJusquA = 0;  // timestamp millis() jusqu'auquel le joueur ne peut pas bouger (pénalité respawn)

  Joueur(int x, int y) {
    super(x, y);
    numero = 1;
    startX = x;
    startY = y;
  }

  Joueur(int x, int y, int num) {
    super(x, y);
    numero = num;
    startX = x;
    startY = y;
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;

    int tempsBloque = max(0, bloqueJusquA - millis());
    boolean bloque  = tempsBloque > 0;

    // Clignotement rapide pendant la pénalité
    if (bloque && frameCount % 14 < 7) {
      fill(30); noStroke();
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      return;
    }

    fill(30); noStroke();
    rect(px, py, TAILLE_TUILE, TAILLE_TUILE);

    color c = (numero == 1) ? color(0, 255, 0) : color(255, 90, 20);
    fill(c);
    ellipseMode(CORNER);
    ellipse(px + 4, py + 4, TAILLE_TUILE - 8, TAILLE_TUILE - 8);

    if (!bloque) {
      fill(0);
      ellipse(px + 12, py + 12, 6, 6);
      ellipse(px + 22, py + 12, 6, 6);
    } else {
      // Compte à rebours affiché sur le joueur
      int secondes = (tempsBloque + 999) / 1000;
      fill(255, 220, 0);
      textSize(18);
      textAlign(CENTER, CENTER);
      text(secondes, px + TAILLE_TUILE / 2, py + TAILLE_TUILE / 2);
    }
  }

  void deplacer(char k, int code, Niveau niveau, GestionnaireJeu jeu) {
    if (!vivant) return;
    if (millis() < bloqueJusquA) return;  // pénalité de respawn : ne peut pas bouger

    int dx = 0, dy = 0;

    if (numero == 1) {
      if (jeu.modeMulti) {
        // En multi : J1 utilise ZQSD/WASD seulement (flèches réservées au J2)
        if      (k == 'z' || k == 'Z' || k == 'w' || k == 'W') dy = -1;
        else if (k == 's' || k == 'S')                          dy =  1;
        else if (k == 'q' || k == 'Q' || k == 'a' || k == 'A') dx = -1;
        else if (k == 'd' || k == 'D')                          dx =  1;
      } else {
        // En solo : J1 utilise flèches + ZQSD/WASD
        if      (code == UP    || k == 'z' || k == 'Z' || k == 'w' || k == 'W') dy = -1;
        else if (code == DOWN  || k == 's' || k == 'S')                          dy =  1;
        else if (code == LEFT  || k == 'q' || k == 'Q' || k == 'a' || k == 'A') dx = -1;
        else if (code == RIGHT || k == 'd' || k == 'D')                          dx =  1;
      }
    } else {
      // J2 : flèches directionnelles
      if      (code == UP)    dy = -1;
      else if (code == DOWN)  dy =  1;
      else if (code == LEFT)  dx = -1;
      else if (code == RIGHT) dx =  1;
    }

    if (dx != 0 || dy != 0) {
      int nx = x + dx;
      int ny = y + dy;

      Element cible = niveau.getElement(nx, ny);

      if (cible == null || cible instanceof Terre) {
        niveau.deplacerElement(this, nx, ny);
      } else if (cible instanceof Diamant) {
        niveau.deplacerElement(this, nx, ny);
        jeu.ajouterScore(1, numero);
      } else if (cible instanceof Rocher && dy == 0) {
        int px2 = nx + dx;
        if (niveau.getElement(px2, ny) == null) {
          niveau.deplacerElement(cible, px2, ny);
          niveau.deplacerElement(this, nx, ny);
        }
      } else if (cible instanceof Sortie) {
        Sortie sortie = (Sortie) cible;
        if (sortie.ouverte) {
          niveau.deplacerElement(this, nx, ny);
          jeu.niveauSuivant();
        }
      }
    }
  }
}
