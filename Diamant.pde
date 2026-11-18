class Diamant extends Element {
  // Vrai uniquement quand le diamant est en mouvement il ne tue le joueur que dans ce cas
  boolean enChute = false;

  Diamant(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;

    // Phase décalée par position pour que chaque diamant clignote à un rythme différent
    float phase = frameCount * 0.08 + x * 0.7 + y * 1.3;
    float t = (sin(phase) + 1) / 2.0;

    fill(30);
    rect(px, py, TAILLE_TUILE, TAILLE_TUILE);

    int r = (int)(0   + t * 120);
    int g = (int)(180 + t * 75);
    int b = (int)(220 + t * 35);
    fill(r, g, b);

    beginShape();
    vertex(px + TAILLE_TUILE/2, py + 5);
    vertex(px + TAILLE_TUILE - 5, py + TAILLE_TUILE/2);
    vertex(px + TAILLE_TUILE/2, py + TAILLE_TUILE - 5);
    vertex(px + 5, py + TAILLE_TUILE/2);
    endShape(CLOSE);

    // Reflet statique sur le coin haut-gauche
    fill(255, 255, 255, (int)(80 + t * 160));
    beginShape();
    vertex(px + TAILLE_TUILE/2, py + 5);
    vertex(px + TAILLE_TUILE/4, py + TAILLE_TUILE/2);
    vertex(px + TAILLE_TUILE/2, py + TAILLE_TUILE/4);
    endShape(CLOSE);

    // Point lumineux qui n'apparaît qu'au pic du clignotement
    if (t > 0.8) {
      float intensite = (t - 0.8) / 0.2;
      fill(255, 255, 255, (int)(intensite * 220));
      ellipseMode(CENTER);
      ellipse(px + TAILLE_TUILE/2, py + 7, 7, 7);
      ellipseMode(CORNER);
    }
  }
}
