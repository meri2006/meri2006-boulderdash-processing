GestionnaireJeu jeu;
Son             son;
Menu            menu;
Editeur         editeur;
Top5            top5;
boolean         dansMenu    = true;
boolean         dansEditeur = false;
boolean         dansTop5    = false;

void setup() {
  size(800, 640);
  frameRate(FPS);
  son  = new Son(this);
  top5 = new Top5();
  menu = new Menu();
}

void draw() {
  background(0);
  if (dansMenu) {
    menu.actualiser();
    menu.afficher();
  } else if (dansEditeur) {
    editeur.actualiser();
    editeur.afficher();
  } else if (dansTop5) {
    top5.actualiser();
    top5.afficher();
  } else {
    jeu.actualiser();
    jeu.afficher();
  }
}

void keyPressed() {
  // key = 0 empêche Processing de fermer la fenêtre sur ESC
  if (keyCode == ESC) {
    key = 0;
    if (dansEditeur) {
      dansEditeur = false;
      dansMenu    = true;
      menu        = new Menu();
    } else if (dansTop5) {
      dansTop5 = false;
      dansMenu = true;
      menu     = new Menu();
    } else if (!dansMenu) {
      if (jeu != null) jeu.enregistrerScore();
      dansMenu = true;
      menu     = new Menu();
    }
    return;
  }

  if (dansTop5) return;

  if (dansMenu) {
    boolean lancer = menu.gererEntree(key, keyCode);
    if (lancer) {
      dansMenu = false;
      if (menu.choix == 3) {
        dansEditeur = true;
        editeur     = new Editeur();
      } else if (menu.choix == 2) {
        dansTop5 = true;
      } else if (menu.choix == 4) {
        jeu = new GestionnaireJeu(true);
      } else {
        jeu = new GestionnaireJeu();
      }
    }
  } else if (dansEditeur) {
    editeur.gererEntree(key, keyCode);
  } else {
    jeu.gererEntree(key, keyCode);
  }
}

void mousePressed() {
  if (!dansEditeur) return;
  // Clic à droite de PALETTE_X = clic sur la palette, sinon on peint la grille
  if (mouseX >= editeur.PALETTE_X) {
    editeur.clicPalette(mouseX, mouseY);
  } else {
    editeur.peindre(mouseX, mouseY, mouseButton == RIGHT);
  }
}

void mouseDragged() {
  if (!dansEditeur) return;
  if (mouseX < editeur.PALETTE_X) {
    editeur.peindre(mouseX, mouseY, mouseButton == RIGHT);
  }
}
