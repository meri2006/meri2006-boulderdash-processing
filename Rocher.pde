class Rocher extends Element {
  // Vrai uniquement quand le rocher est en mouvement — il ne tue le joueur que dans ce cas
  boolean enChute = false;

  Rocher(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    fill(30);
    rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
    fill(120);
    ellipseMode(CORNER);
    ellipse(px + 2, py + 2, TAILLE_TUILE - 4, TAILLE_TUILE - 4);
    fill(180);
    ellipse(px + 8, py + 8, TAILLE_TUILE/3, TAILLE_TUILE/3);
  }
}
