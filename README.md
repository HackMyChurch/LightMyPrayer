# Light My Prayer (HackMyChurch)
Projet « Light My Prayer »

---

## Dispositif

Ce dispositif permet aux utilisateurs d'écrire un message manuscrit, une prière ou une intention de prière, de définir un destinataire ou une personne concernée en l'écrivant sur un galet, puis de soumettre l'ensemble pour voir s'afficher aléatoirement ces données projetées sur une surface visible.

Techniquement, l'utilisateur dessine des caractères avec son doigt sur la surface tactile (écran touch), puis écrit avec un marqueur sur un galet qu'il vient déposer sur une trappe, cachant un capteur de lumière. Ce capteur de lumière, sous un seuil défini, déclenche la capture d'une photo via une webcam située au dessus. Une fois cette photo prise, la trappe s'ouvre grâce au Servo moteur et le galet tombe, caché dans le dispositif. Une fois la trappe revenue à sa position initiale par contre-poids, le Servo moteur rebloque la trappe et l'écran touch repart à zéro pour accueillir un nouvel utilisateur et/ou nouveau message.

## Fonctionnement

Le dispositif est constitué de :
* Un écran touch
* Un ordinateur
* Une carte Arduino et sa breadboard
* Un Servo moteur
* Un capteur de lumière
* Un objet fabriqué sur mesure avec une trappe, un espace pour l'écran et un espace (inutilisé) pour la sortie d'une impression papier A5

## Électronique

![Schema Arduino](/Arduino/Schema.png?raw=true "Schema Arduino")

![Schema Arduino Zoom](/Arduino/Schema-Zoom.png?raw=true "Schema Arduino Zoom")

## Photos

La signalétique d'utilisation a été placée par dessus la structure en impression vinyle.
