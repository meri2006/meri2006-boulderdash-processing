class GestionnaireJeu {
  Niveau         niveau;
  MoteurPhysique physique;

  boolean modeMulti    = false;

  // --- Solo ---
  int etat;
  int diamantsRecoltes;
  int scoreGlobal   = 0;
  int scoreCible    = 10;
  int indexNiveau   = 0;
  int vies          = 3;

  int dernierTick      = 0;
  int intervalleTick   = 150;

  int tempsInitial;
  int tempsRestant;
  int dernierTempsMillis;
  int pauseDebut = 0;

  boolean scoreDejaEnregistre = false;
  boolean nouvelleEntreeTop5  = false;
  String  pseudoEnCours       = "";
  int     etatApres           = ETAT_GAMEOVER;

  // --- Multi ---
  int scoreJ1      = 0;
  int scoreJ2      = 0;
  int diamantsJ1   = 0;
  int diamantsJ2   = 0;
  int timerGlobal  = 300;
  boolean avancerNiveauAuto = false;

  // Constructeur solo
  GestionnaireJeu() {
    modeMulti = false;
    physique  = new MoteurPhysique(this);
    initialiserNiveau();
  }

  // Constructeur multi
  GestionnaireJeu(boolean multi) {
    modeMulti = multi;
    physique  = new MoteurPhysique(this);
    if (modeMulti) initialiserNiveauMulti();
    else           initialiserNiveau();
  }

  // ─── SOLO ───────────────────────────────────────────────────────────────

  void initialiserNiveau() {
    etat                = ETAT_JEU;
    diamantsRecoltes    = 0;
    scoreDejaEnregistre = false;
    nouvelleEntreeTop5  = false;
    pseudoEnCours       = "";
    dernierTempsMillis  = millis();
    dernierTick         = millis();

    niveau       = new Niveau(indexNiveau + 1);
    scoreCible   = niveau.nbDiamantsRequis;
    tempsInitial = niveau.estBonus ? 45 : 150;
    tempsRestant = tempsInitial;

    if (niveau.estBonus && niveau.sortie != null) {
      niveau.sortie.ouverte = true;
    }

    if (!niveau.succesChargement) {
      son.victoire();
      terminerPartie(ETAT_VICTOIRE);
    }
  }

  void perdreVie() {
    vies--;
    if (vies <= 0) {
      vies = 0;
      terminerPartie(ETAT_GAMEOVER);
    } else {
      initialiserNiveau();
    }
  }

  void terminerPartie(int etatCible) {
    if (!scoreDejaEnregistre && scoreGlobal > 0 && top5.estNouveauTop(scoreGlobal)) {
      nouvelleEntreeTop5 = true;
      etatApres          = etatCible;
      pseudoEnCours      = "";
      etat               = ETAT_SAISIE_PSEUDO;
    } else {
      enregistrerScore();
      etat = etatCible;
    }
  }

  void enregistrerScore() {
    if (!scoreDejaEnregistre && scoreGlobal > 0) {
      nouvelleEntreeTop5  = top5.estNouveauTop(scoreGlobal);
      top5.ajouterScore(scoreGlobal, pseudoEnCours.trim().length() > 0 ? pseudoEnCours.trim() : "");
      scoreDejaEnregistre = true;
    }
  }

  void confirmerPseudo() {
    if (!scoreDejaEnregistre && scoreGlobal > 0) {
      String nom = pseudoEnCours.trim().length() > 0 ? pseudoEnCours.trim() : "???";
      top5.ajouterScore(scoreGlobal, nom);
      scoreDejaEnregistre = true;
      nouvelleEntreeTop5  = true;
    }
    etat = etatApres;
  }

  // ─── MULTI ──────────────────────────────────────────────────────────────

  void initialiserNiveauMulti() {
    etat              = ETAT_JEU;
    diamantsJ1        = 0;
    diamantsJ2        = 0;
    avancerNiveauAuto = false;
    dernierTempsMillis = millis();
    dernierTick        = millis();

    niveau     = new Niveau(indexNiveau + 1, true);
    scoreCible = niveau.nbDiamantsRequis;

    if (!niveau.succesChargement) {
      finDePartieMulti();
      return;
    }
    if (niveau.estBonus && niveau.sortie != null) {
      niveau.sortie.ouverte = true;
    }
  }

  void finDePartieMulti() {
    etat = ETAT_FIN_MULTI;
  }

  // Respawn d'un joueur à sa position de départ avec pénalité de 3 secondes
  void respawnerJoueur(Joueur j) {
    // Retirer le joueur de sa case actuelle si c'est bien lui qui l'occupe
    if (j.x >= 0 && j.x < niveau.cols && j.y >= 0 && j.y < niveau.rows) {
      if (niveau.grille[j.x][j.y] == j) niveau.grille[j.x][j.y] = null;
    }
    // Forcer le placement à la position de départ
    j.x = j.startX;
    j.y = j.startY;
    j.vivant      = true;
    j.bloqueJusquA = millis() + 3000;
    if (j.startX >= 0 && j.startX < niveau.cols && j.startY >= 0 && j.startY < niveau.rows) {
      niveau.grille[j.startX][j.startY] = j;
    }
  }

  // ─── COMMUN ─────────────────────────────────────────────────────────────

  void niveauSuivant() {
    indexNiveau++;
    if (modeMulti) initialiserNiveauMulti();
    else           initialiserNiveau();
  }

  void ajouterScore(int points, int joueurNum) {
    son.collecterDiamant();
    if (modeMulti) {
      if (joueurNum == 1) { scoreJ1 += points * 10; diamantsJ1 += points; }
      else                { scoreJ2 += points * 10; diamantsJ2 += points; }
      int total = diamantsJ1 + diamantsJ2;
      if (total >= scoreCible) {
        avancerNiveauAuto = true;  // différé pour ne pas corrompre la grille en cours de déplacement
      }
    } else {
      diamantsRecoltes += points;
      scoreGlobal      += points * 10;
      if (diamantsRecoltes >= scoreCible && niveau.sortie != null && !niveau.sortie.ouverte) {
        niveau.sortie.ouverte = true;
        son.sortieOuverte();
      }
    }
  }

  void ajouterBonus(int points) {
    if (modeMulti) {
      scoreJ1 += points / 2;
      scoreJ2 += points / 2;
    } else {
      scoreGlobal += points;
    }
  }

  // ─── BOUCLE ─────────────────────────────────────────────────────────────

  void actualiser() {
    if (etat == ETAT_PAUSE)        return;
    if (etat == ETAT_SAISIE_PSEUDO) return;
    if (etat != ETAT_JEU)          return;

    int t = millis();

    if (modeMulti) {
      if (t - dernierTempsMillis >= 1000) {
        timerGlobal--;
        dernierTempsMillis += 1000;
        if (timerGlobal <= 0) {
          timerGlobal = 0;
          finDePartieMulti();
          return;
        }
      }
    } else {
      if (t - dernierTempsMillis >= 1000) {
        tempsRestant--;
        dernierTempsMillis += 1000;
        if (tempsRestant <= 0) {
          tempsRestant = 0;
          son.joueurMort();
          perdreVie();
          return;
        }
      }
    }

    // Auto-avancement multi : tous les diamants collectés → niveau suivant
    if (modeMulti && avancerNiveauAuto) {
      avancerNiveauAuto = false;
      son.sortieOuverte();
      niveauSuivant();
      return;
    }

    if (t - dernierTick > intervalleTick) {
      physique.actualiser(niveau);
      dernierTick = t;

      if (modeMulti) {
        if (niveau.joueur  != null && !niveau.joueur.vivant) {
          son.joueurMort();
          respawnerJoueur(niveau.joueur);
        }
        if (niveau.joueur2 != null && !niveau.joueur2.vivant) {
          son.joueurMort();
          respawnerJoueur(niveau.joueur2);
        }
      } else {
        if (niveau.joueur != null && !niveau.joueur.vivant) {
          son.joueurMort();
          perdreVie();
        }
      }
    }
  }

  void gererEntree(char k, int code) {
    if (!modeMulti && etat == ETAT_SAISIE_PSEUDO) {
      if (code == ENTER || k == '\n' || k == '\r') {
        confirmerPseudo();
      } else if (code == BACKSPACE) {
        if (pseudoEnCours.length() > 0)
          pseudoEnCours = pseudoEnCours.substring(0, pseudoEnCours.length() - 1);
      } else if (k >= 32 && k < 127 && pseudoEnCours.length() < 10) {
        pseudoEnCours += k;
      }
      return;
    }

    if (k == 'p' || k == 'P') {
      if (etat == ETAT_JEU) {
        etat       = ETAT_PAUSE;
        pauseDebut = millis();
        son.menuSelect();
      } else if (etat == ETAT_PAUSE) {
        int duree = millis() - pauseDebut;
        dernierTempsMillis += duree;
        dernierTick        += duree;
        etat = ETAT_JEU;
        son.menuSelect();
      }
      return;
    }

    if (k == 'm' || k == 'M') {
      son.basculer();
      return;
    }

    if (etat == ETAT_PAUSE) return;

    if (etat != ETAT_JEU) {
      if (modeMulti) {
        indexNiveau = 0;
        scoreJ1     = 0;
        scoreJ2     = 0;
        diamantsJ1  = 0;
        diamantsJ2  = 0;
        timerGlobal = 300;
        initialiserNiveauMulti();
      } else {
        enregistrerScore();
        indexNiveau = 0;
        scoreGlobal = 0;
        vies        = 3;
        initialiserNiveau();
      }
      return;
    }

    if (niveau.joueur != null) {
      niveau.joueur.deplacer(k, code, niveau, this);
    }
    if (modeMulti && niveau.joueur2 != null) {
      niveau.joueur2.deplacer(k, code, niveau, this);
    }
  }

  // ─── AFFICHAGE ──────────────────────────────────────────────────────────

  void afficher() {
    if (niveau != null && niveau.succesChargement) {
      niveau.afficher();
    }

    if (modeMulti) {
      afficherHUDMulti();
    } else {
      afficherHUDSolo();
    }
  }

  void afficherHUDMulti() {
    fill(0, 170);
    noStroke();
    rect(0, 0, width, 40);

    // Joueur 1 (gauche, vert)
    fill(0, 220, 0);
    textSize(15);
    textAlign(LEFT, CENTER);
    text("J1: " + scoreJ1 + " pts", 10, 13);
    fill(160);
    textSize(12);
    text("D: " + diamantsJ1 + " / " + scoreCible, 10, 30);

    // Centre : Niveau + Timer
    fill(255);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("Niveau " + (indexNiveau + 1), width / 2, 13);
    if (timerGlobal <= 30) fill(255, 50, 50);
    else if (timerGlobal <= 60) fill(255, 180, 0);
    else fill(255, 220, 0);
    textSize(15);
    text("Temps: " + timerGlobal + "s", width / 2, 30);

    // Joueur 2 (droite, orange)
    fill(255, 90, 20);
    textSize(15);
    textAlign(RIGHT, CENTER);
    text("J2: " + scoreJ2 + " pts", width - 10, 13);
    fill(160);
    textSize(12);
    text("D: " + diamantsJ2 + " / " + scoreCible, width - 10, 30);

    // Son
    fill(son.sonActif ? color(80, 255, 80) : color(200, 80, 80));
    textSize(12);
    textAlign(LEFT, BOTTOM);
    text(son.sonActif ? "[M] Son:ON" : "[M] Son:OFF", 8, height - 5);

    // Contrôles
    fill(120);
    textSize(12);
    textAlign(RIGHT, BOTTOM);
    text("J1:ZQSD  J2:IJKL  |  [P]Pause  |  [ESC]Menu", width - 8, height - 5);

    if (etat == ETAT_PAUSE) {
      fill(0, 190);
      rect(0, 0, width, height);
      fill(255, 220, 0);
      textSize(64);
      textAlign(CENTER, CENTER);
      text("PAUSE", width / 2, height / 2 - 30);
      fill(200);
      textSize(20);
      text("Appuyez sur P pour continuer", width / 2, height / 2 + 35);
    }

    if (etat == ETAT_FIN_MULTI) {
      fill(0, 210);
      rect(0, 0, width, height);

      String msg;
      color cMsg;
      if (scoreJ1 > scoreJ2) {
        msg  = "JOUEUR 1 GAGNE !";
        cMsg = color(0, 255, 0);
      } else if (scoreJ2 > scoreJ1) {
        msg  = "JOUEUR 2 GAGNE !";
        cMsg = color(255, 90, 20);
      } else {
        msg  = "EGALITE !";
        cMsg = color(255, 220, 0);
      }

      fill(cMsg);
      textSize(58);
      textAlign(CENTER, CENTER);
      text(msg, width / 2, height / 2 - 90);

      // Scores finaux
      fill(0, 220, 0);
      textSize(26);
      text("J1  " + scoreJ1 + " pts", width / 2 - 150, height / 2);
      fill(255, 90, 20);
      text("J2  " + scoreJ2 + " pts", width / 2 + 150, height / 2);

      fill(200);
      textSize(18);
      textAlign(CENTER, CENTER);
      text("Appuyez sur une touche pour rejouer", width / 2, height / 2 + 60);
      fill(140);
      textSize(14);
      text("ESC = retour au menu", width / 2, height / 2 + 90);
    }
  }

  void afficherHUDSolo() {
    fill(0, 160);
    noStroke();
    rect(0, 0, width, 40);

    fill(255);
    textSize(20);
    textAlign(LEFT, CENTER);
    text("Niveau " + (indexNiveau + 1), 10, 20);
    if (niveau != null && niveau.estBonus) {
      fill(255, 180, 0);
      textSize(11);
      text("BONUS", 10, 33);
      fill(255);
      textSize(20);
    }

    textAlign(CENTER, CENTER);
    text("Diamants: " + diamantsRecoltes + " / " + scoreCible, width * 0.35, 20);
    text("Score: " + scoreGlobal, width * 0.55, 20);

    float T  = TAILLE_TUILE;
    float s  = 28.0 / T;
    float iy = (40 - 28) / 2.0;
    float ix = width * 0.68;
    for (int i = 0; i < 3; i++) {
      pushMatrix();
      translate(ix + i * 32, iy);
      scale(s);
      if (i < vies) {
        fill(30);        noStroke(); rect(0, 0, T, T);
        fill(0, 255, 0); ellipseMode(CORNER); ellipse(4, 4, T-8, T-8);
        fill(0);         ellipse(12, 12, 6, 6); ellipse(22, 12, 6, 6);
      } else {
        fill(30);        noStroke(); rect(0, 0, T, T);
        fill(60, 90, 60); ellipseMode(CORNER); ellipse(4, 4, T-8, T-8);
      }
      popMatrix();
    }
    ellipseMode(CENTER);

    textAlign(RIGHT, CENTER);
    if (tempsRestant <= 10) fill(255, 50, 50);
    else fill(255);
    text("Temps: " + tempsRestant, width - 10, 20);

    fill(son.sonActif ? color(80, 255, 80) : color(200, 80, 80));
    textSize(13);
    textAlign(LEFT, BOTTOM);
    text(son.sonActif ? "[M] Son : ON" : "[M] Son : OFF", 8, height - 5);

    textAlign(RIGHT, BOTTOM);
    fill(120);
    textSize(13);
    text("[P] Pause  |  [ESC] Menu", width - 8, height - 5);

    if (etat == ETAT_PAUSE) {
      fill(0, 190);
      rect(0, 0, width, height);
      fill(255, 220, 0);
      textSize(64);
      textAlign(CENTER, CENTER);
      text("PAUSE", width/2, height/2 - 30);
      fill(200);
      textSize(20);
      text("Appuyez sur P pour continuer", width/2, height/2 + 35);
      fill(130);
      textSize(15);
      text("ESC = retour au menu", width/2, height/2 + 72);
    }

    if (etat == ETAT_SAISIE_PSEUDO) {
      fill(0, 200);
      rect(0, 0, width, height);
      fill(255, 215, 0);
      textSize(46);
      textAlign(CENTER, CENTER);
      text("NOUVEAU TOP 5 !", width/2, height/2 - 105);
      fill(255);
      textSize(22);
      text("Score : " + scoreGlobal, width/2, height/2 - 58);
      fill(200);
      textSize(20);
      text("Entrez votre pseudo :", width/2, height/2 - 12);
      fill(20);
      noStroke();
      rect(width/2 - 160, height/2 + 12, 320, 54, 10);
      fill(255, 215, 0);
      textSize(30);
      text(pseudoEnCours + (frameCount % 60 < 30 ? "|" : " "), width/2, height/2 + 39);
      fill(150);
      textSize(15);
      text("ENTRÉE pour valider   (max 10 caractères)", width/2, height/2 + 100);
    }

    if (etat == ETAT_GAMEOVER) {
      fill(0, 180);
      rect(0, 0, width, height);
      fill(255, 50, 50);
      textSize(64);
      textAlign(CENTER, CENTER);
      text("GAME OVER", width/2, height/2 - 60);
      fill(255, 80, 80);
      textSize(22);
      text("Plus de vies !", width/2, height/2 - 8);
      fill(255);
      textSize(22);
      text("Score : " + scoreGlobal, width/2, height/2 + 22);
      if (nouvelleEntreeTop5) {
        fill(255, 215, 0);
        textSize(20);
        text("NOUVEAU TOP 5 !", width/2, height/2 + 52);
        fill(255);
        textSize(16);
        text("Appuyez sur une touche pour rejouer", width/2, height/2 + 78);
        fill(140);
        textSize(14);
        text("ESC = retour au menu", width/2, height/2 + 104);
      } else {
        fill(255);
        textSize(18);
        text("Appuyez sur une touche pour rejouer", width/2, height/2 + 62);
        fill(140);
        textSize(14);
        text("ESC = retour au menu", width/2, height/2 + 82);
      }
      fill(100);
      textSize(13);
      text("Meilleur score : " + (top5.scores[0] > 0 ? str(top5.scores[0]) : "---"), width/2, height/2 + 110);
    }

    if (etat == ETAT_VICTOIRE) {
      fill(0, 180);
      rect(0, 0, width, height);
      fill(50, 255, 80);
      textSize(64);
      textAlign(CENTER, CENTER);
      text("VICTOIRE !", width/2, height/2 - 50);
      fill(255);
      textSize(22);
      text("Score final : " + scoreGlobal, width/2, height/2 + 5);
      if (nouvelleEntreeTop5) {
        fill(255, 215, 0);
        textSize(20);
        text("NOUVEAU TOP 5 !", width/2, height/2 + 34);
        fill(255);
        textSize(16);
        text("Appuyez sur une touche pour rejouer", width/2, height/2 + 62);
        fill(140);
        textSize(14);
        text("ESC = retour au menu", width/2, height/2 + 90);
      } else {
        fill(255);
        textSize(18);
        text("Appuyez sur une touche pour rejouer", width/2, height/2 + 50);
        fill(140);
        textSize(14);
        text("ESC = retour au menu", width/2, height/2 + 82);
      }
      fill(100);
      textSize(13);
      text("Meilleur score : " + (top5.scores[0] > 0 ? str(top5.scores[0]) : "---"), width/2, height/2 + 110);
    }
  }
}
