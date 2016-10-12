# Multiple-Images-Meshing
A Matlab modelisation project, made in a team during my 2nd year at the ENSEEIHT.

The aim is to turn a real object into a 3D mesh, thanks to a large number of pictures taken in different angles.

The code is written in french.

## TP MODELISATION
### MAXIME PESCHARD & GUILLAUME SINGLAND

- lancer le script "launch.m" pour observer, sur une image choisie arbitrairement, le résultat de l'ensemble des travaux demandés.
  * Figure 1 : position des germes sur l'image
  * Figure 2 : image segmentée après l'appel à kmeans
  * Figure 3 : image segmentée après fusion des petites régions
  * PAUSE - Appuyer sur n'importe quelle touche pour continuer
  * Figure 4 : image segmentée fond / forme
  * PAUSE - Appuyer sur n'importe quelle touche pour continuer
  * Figure 5 : frontière du dinosaure (avec point de départ en rouge)
  * Figure 6 : points du squelette
  * Figure 7 : dinosaure "reconstruit" par affichage des cercles maximaux
  * Figure 8 : axe médian
  * PAUSE - Appuer sur n'importe quelle touche pour continuer
  * Figure 9 : image dont on grossit les rayons par un facteur s
  * Figure 10 : squelette filtré
- lancer le script "mask.m" pour obtenir le fichier mask.mat
- lancer le script "TP_maillage.m" pour effectuer le processus de maillage jusqu'au retrait des mauvais tétraèdres.
- lancer le script "TP_maillage_suite.m" pour effectuer la fin du processus (ie la sélection des faces de la surface).
