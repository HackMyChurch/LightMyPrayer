
// Projet "Light My Prayer"
// de l'événement HackMyChurch 2015
// http://www.hackmychurch.com/

// Code Processing qui exécute le dispositif
// et qui écoute les données Arduino (via Serial)
// Testé avec Processing 2.2.1
// Fonctionne sous Mac et Linux

///////////////////////////////////////////////////////

// Note [1] : 
//        Sur surface Touch, souci de comportement,
//        lignes qui se joignent quand on lève le doigt
//        pour écrire plus loin

///////////////////////////////////////////////////////

// Note [2] : 
//        Un "bug" (a feature, plus précisément, haem)
//        a été constaté lors de l'exploitation
//        en temps réel des images générées
//        (page web + requêtes AJAX régulières).

//        En effet, la librairie `gifAnimation`
//        crée le fichier GIF dès la première frame
//        et ajoute simplement des frames au fur et à mesure
//        à ce même fichier. Puique l'image n'est alors pas
//        stockée dans le cache mais créée dès le début
//        de l'enregistrement (donc présente dans le dossier),
//        la requête AJAX récupère l'image qui ne s'affiche pas
//        dans la page web (broken image).

// Solutions : 
//      - Il faudrait ne pas récupérer la dernière image du dossier
//        en AJAX (mais temps réel un peu faussé)
//      - Il faudrait tester la validité du GIF dans la requête AJAX
//        (mais probabilité de tomber sur un GIF valide mais incomplet (en cours))
//      - Il faudrait alors stocker le GIF en cours
//        dans un nom particulier (pré ou suffixe)
//        puis changer son nom à la clôture du GIF

// Doc de la librairie `gifAnimation` :
// http://extrapixel.github.io/gif-animation/

///////////////////////////////////////////////////////

// Note [3] : 
//        Sur Linux, le timestamp ne semblait pas
//        se rafraîchir à chaque nouveau GIF
//        (problème de java.util.Date ?)
//        (autre format pour récupérer le timestamp ?)

// Solution :
//        Créer une variable incrémentielle
//        plutôt que le timestamp
//        (mais quid lors du redémarrage du script ?)

///////////////////////////////////////////////////////

import gifAnimation.*;
import processing.video.*;
import processing.serial.*;
import java.util.Date;

Serial port;
Capture cam;

// On crée un objet GIF
// de la librairie `gifAnimation`
GifMaker Gif;

// On va récupérer le timestamp de cette manière
Date d = new Date();
long timestamp;

// On va utiliser un timer
// pour afficher un écran intermédiaire
// un certain temps
Timer timerCleaning = new Timer(0);

// Il est possible d'activer ou non
// l'appel à la webcam ou à Arduino
// pour les phases de debug
Boolean useWebcam = false;
Boolean useArduino = false;

// Pour savoir dans quel écran en est le script,
// la variable STATE contiendra l'état courant
int STATE = 0;

// Les "constantes" suivantes définissent
// les trois états successifs de STATE
// 0 > 1 > 2 > 0 > 1 > 2 > …
int WAITING = 0; 
int DOING = 1; 
int CLEANING = 2;

int WIDTH = 800;
int HEIGHT = 600;

void setup() {
  size(WIDTH, HEIGHT);
  background(0);
  smooth();
  frameRate(15);

  if (useArduino) {
    printArray(Serial.list());

    // Le port Arduino est défini ici
    String portName = Serial.list()[2];

    port = new Serial(this, portName, 9600);
    port.clear();
    port.bufferUntil('\n');
  }

  if (useWebcam) {
    String[] cameras = Capture.list();

    if (cameras.length == 0) {
      exit();
    } else {
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }

      // La webcam à utiliser est définie ici
      cam = new Capture(this, cameras[0]);
      cam.start();
    }
  }
}

void draw() {

  // WAITING
  // L'écran attend l'interaction d'un utilisateur
  // et affiche un message d'introduction ou un tutoriel
  // (ici, par contrainte de temps, un bel écran rouge)

  if (is(WAITING)) {
    background(255, 0, 0);
  }


  // DOING
  // L'écran a été stimulé par un utilisateur
  // et cet utilisateur est en train d'écrire
  // et/ou d'écrire sur le galet
  // et/ou de poser le galet dans l'espace associé  

  if (is(DOING)) {
    // Couleur du texte manuscrit
    stroke(255);

    // Largeur du trait du texte manuscrit
    strokeWeight(10);

    // Si l'utilisateur écrit (touch ou souris)
    if (mousePressed) {
      noFill();

      // Pour avoir une "écriture fluide",
      // on dessine une ligne entre la position précédente
      // et la position courante
      // (souci avec le touch : voir Note [1])
      line(mouseX, mouseY, pmouseX, pmouseY);

      // On ajoute la frame courante au GIF
      Gif.setDelay(1);
      Gif.addFrame();

      // On crée une zone en haut à gauche
      // pour recommencer le message manuscrit
      if (mouseX < 50 && mouseY < 50) {
        initGIF();
        background(0);
      }

      // On crée une zone en haut à droite
      // pour envoyer le message sans galet
      if (mouseX > WIDTH-50 && mouseY < 50) {
        saveAll();
      }
    }
  }

  // CLEANING
  // L'utilisateur a déposé le galet
  // ou a envoyé le message via l'angle :
  // on affiche un message intermédiaire
  // de confirmation (ou un super rectangle vert)

  if (is(CLEANING)) {
    background(0, 255, 0);
    
    // On check le temps restant
    // pour passer à l'état suivant ou non
    checkTimerCleaning();
  }
}



void initGIF() {
  // On définit l'id du timestamp
  timestamp = d.getTime()/1000; 

  // On crée le fichier GIF dans le dossier export/
  // sous la forme `prayer123456789.gif`
  Gif = new GifMaker(this, "export/prayer"+timestamp+".gif");
  
  // On enregistre le GIF
  // pour qu'il ne se que lise qu'une fois
  // (mais ça n'a jamais marché chez nous,
  // on récupérait des GIF qui loop)
  Gif.setRepeat(1); 
  
  // On définit le noir
  // comme couleur transparente du GIF
  Gif.setTransparent(0, 0, 0);
  
  Gif.setQuality(40);
}

// Pour checker l'écran courant,
// une petite fonction pratique
Boolean is(int state) {
  return (state == STATE);
}

// Fonction pour changer l'écran
void changeStateTo(int state) {
  STATE = state;
}


void serialEvent(Serial port) {
  String get = port.readStringUntil('\n');

  if (get != null) {
    // On récupère la valeur d'Arduino
    int lightSensor = int(trim(get));

    // Affichez la valeur reçue avec :
    // println(lightSensor);

    // Si on attend justement
    // que le capteur déclenche le Servo
    if (is(DOING)) {
      
      // Si la valeur du capteur
      // est en dessous du seuil
      if (lightSensor < 200) {
        
        // On déclenche la suite :
        // enregistrement du GIF,
        // changement de l'état de l'écran,
        // écran intermédiaire
        saveAll();
      }
    }
  }
}

// Vous pouvez redéfinir le temps d'apparition
// de l'écran intermédiaire en millisecondes
void startTimerCleaning() {
  timerCleaning = new Timer(3000);
  timerCleaning.start();
}

void checkTimerCleaning() {
  if (timerCleaning.isFinished()) {
    // Si le timer est terminé,
    // on passe de l'état CLEANING
    // à l'état WAITING
    changeStateTo(WAITING);
  }
}

// Fonction qui gère l'enregistrement du GIF,
// qui prend la photo du galet
// et qui passe à l'écran suivant

void saveAll() {
  
  // Si l'enregistrement du GIF s'est bien déroulé
  if (Gif.finish()) {

    // Si on utilise la webcam
    if (useWebcam) {
      if (cam.available() == true) {
        cam.read();
      }
      
      image(cam, 0, 0);
      
      // On active un filtre pour vraiment contraster
      filter(THRESHOLD);
      
      // Puis on enregistre la capture webcam
      saveFrame("export/stone"+timestamp+".png");
    }

    // Enfin, on passe à l'écran intermédiaire CLEANING
    // et on démarre le timer associé
    changeStateTo(CLEANING);
    startTimerCleaning();
  }
}

