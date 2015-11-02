//
// Projet "Light My Prayer"
// de l'événement HackMyChurch 2015
// http://www.hackmychurch.com/
// 
// Code Arduino à téléverser sur la carte Arduino
// Testé avec une Arduino Uno
// Schéma technique disponible sur GitHub
// Kevin Vennitti (@kevinvennitti)

// Les pin output sont définis ici,
// il est possible de les modifier
// en adaptant le circuit électronique

#include <Servo.h>

Servo servo;  // Declaration du Servo moteur 

void setup() {
  Serial.begin(9600);
  
  // Pin output du Servo moteur
  servo.attach(9);
}

void loop() {
  // On lit la valeur du lightSensor
  // sur la pin A0
  int lightValue = analogRead(A0);
  
  // On affiche cette valeur
  // pour la communiquer a Processing
  Serial.println(lightValue);
  
  // Delay pour la stabilite du code
  delay(1);
  
  // Pour eviter un handshake Processing/Arduino,
  // on teste directement la valeur du light sensor
  // pour activer ou non le Servo moteur ;
  // l'ideal serait quand meme que Processing
  // ordonne a Arduino lorsqu'il faut reagir
  
  // Le seuil est a etalonner selon l'environnement  
  if (lightValue < 200) {
    // Pour activer la trappe, on attend
    // quelques secondes avant de deverouiller le Servo (A)
    // (le temps que la webcam capture la photo),
    // puis on pivote le Servo (B)
    // puis on attend quelques secondes (C)
    // avant de rtablir la position du Servo (D)
    delay(2000);       // (A)
    servo.write(180);  // (B)               
    delay(5000);       // (C)
    servo.write(90);   // (D)
  }
}
