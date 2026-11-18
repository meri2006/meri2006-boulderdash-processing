class Sortie extends Element {
  // Bloquée tant que le joueur n'a pas collecté assez de diamants
  boolean ouverte = false;

  Sortie(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (ouverte) {
      fill(30);
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill(20, 20, 20);
      rect(px + 5, py + 5, TAILLE_TUILE - 10, TAILLE_TUILE - 10);
      fill(255, 255, 0);
      textSize(12);
      textAlign(CENTER, CENTER);
      text("OUT", px + TAILLE_TUILE/2, py + TAILLE_TUILE/2);
    } else {
      fill(150, 0, 0);
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill(100, 0, 0);
      rect(px + 5, py + 5, TAILLE_TUILE - 10, TAILLE_TUILE - 10);
      stroke(50, 0, 0);
      strokeWeight(2);
      line(px + TAILLE_TUILE/2, py, px + TAILLE_TUILE/2, py + TAILLE_TUILE);
      noStroke();
    }
  }
}
