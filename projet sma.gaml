/**
* Name: Voitureaeriennefinal
* Based on the internal empty template. 
* Author: ADMIN
* Tags: 
*/
model Voitureaeriennefinal

/* Insert your model definition here */
global { //chargement des fichiers shapes
	file fichier_forme <- file("../includes/forme.shp");
	file fichier_route <- file("../includes/ligne.shp");
	file fichier_airport <- file("../includes/aeroport.shp");
	file fichier_station <- file("../includes/station.shp");
	point france_chine_1 <- {250, 142};
	point france_chine_2 <- {530, 45};
	point france_chine_3 <- {740, 145};
	point france_chine_4 <- {250, 190};
	point france_chine_5 <- {470, 235};
	point france_chine_6 <- {740, 180};
	point chine_australie_1 <- {995, 165};
	point chine_australie_5 <- {885, 230};
	point chine_australie_2 <- {1160, 190};
	point chine_australie_3 <- {1230, 560};
	point chine_australie_4 <- {1200, 650};
	point chine_australie_7 <- {1140, 650};
	point chine_australie_6 <- {900, 390};
	point congo_australie_6 <- {1020, 730};
	point france_congo_5 <- {280, 290};
	point congo_australie_2 <- {635, 370};
	point congo_australie_5 <- {710, 760};
	point congo_australie_3 <- {1075, 650};
	point congo_austalie_7 <- {340, 500};
	point congo_australie_4 <- {430, 630};
	//point chine_australie_2 <- {150, 440};
	point france_congo_4 <- {150, 220};
	//point chine_australie_4 <- {50, 220};
	point france_congo_2 <- {20, 350};
	point france_congo_1 <- {50, 220};
	point congo_australie_1 <- {350, 470};
	point chine_austalie_8 <- {350, 470};
	point france_congo_3 <- {128, 430};
	point france_congo_6 <- {260, 430};
	point tour_de_controle_chine <- {730, 50};
	point tour_de_controle_congo <- {160, 650};
	point tour_de_controle_australie <- {1100, 865};
	point tour_de_controle_france <- {250, 50};
	geometry shape <- envelope(fichier_forme);
	int taux_par_quantite <- 20; // Le taux  à appliquer pour chaque par tonne chargement de dechargement des marchandises
	float taxe <- 0.1; //L' aeroport  va prendre 10% pour chaque chargement et dechargement sur le montant total a payer
	init {
		create forme from: fichier_forme {
		}

		create route from: fichier_route {
		}

		create airport from: fichier_airport {
		}

		create station from: fichier_station {
		}

		list les_stat <- list(station);
		les_stat[0].nom <- "Australie";
		les_stat[0].couleur <- #yellow;
		les_stat[1].nom <- "Chine";
		les_stat[1].couleur <- #skyblue;
		les_stat[2].nom <- "France";
		les_stat[2].couleur <- #green;
		les_stat[3].nom <- "Congo";
		les_stat[3].couleur <- #crimson;
		list les_stations <- list(station);
		list les_aeroports <- list(airport);
		les_aeroports[0].nom <- "Australie";
		les_aeroports[1].nom <- "Congo";
		les_aeroports[2].nom <- "Chine";
		les_aeroports[3].nom <- "France";
		loop i from: 0 to: 3 {
			if (i = 0) {
				create tour_controle number: 1 {
					location <- tour_de_controle_france;
					nom <- "tour_de_controle_france";
				}

			}

			if (i = 1) {
				create tour_controle number: 1 {
					location <- tour_de_controle_congo;
					nom <- "tour_de_controle_congo";
				}

			}

			if (i = 2) {
				create tour_controle number: 1 {
					location <- tour_de_controle_australie;
					nom <- "tour_de_controle_australie";
				}

			}

			if (i = 3) {
				create tour_controle number: 1 {
					location <- tour_de_controle_chine;
					nom <- "tour_de_controle_chine";
				}

			}

		}

		create avion number: 30 {
			location <- any_location_in(one_of(les_stations[0], les_stations[1], les_stations[2], les_stations[3]));
			list<station> stations <- list(station) where ((each distance_to self <= 10));
			list<airport> les_aeros <- list(airport) where ((each distance_to self <= 10));
			couleur <- stations[0].couleur;
			affectation_aeroport <- les_aeros[0].nom;
			if (affectation_aeroport = "Congo") {
				destination_finale <- one_of("France", "Australie", "Chine");
			}

			if (affectation_aeroport = "France") {
				destination_finale <- one_of("Congo", "Australie", "Chine");
			}

			if (affectation_aeroport = "Australie") {
				destination_finale <- one_of("France", "Congo", "Chine");
			}

			if (affectation_aeroport = "Chine") {
				destination_finale <- one_of("France", "Australie", "Congo");
			}

		}

	}

}

species forme {

	aspect default {
		draw shape color: #grey;
	}

}

species route {

	aspect default {
		draw shape color: #white;
	}

}

species station {
	string nom;
	rgb couleur;

	aspect default {
		draw shape color: couleur;
	}

}

species airport {
	string nom;
	rgb couleur <- #black;

	aspect default {
		draw shape color: couleur;
	}

}

species avion skills: [moving] {
	string affectation_aeroport;
	int vitesse_de_chargement <- rnd(1, 5, 1);
	int capacite_marchandise_transporter <- rnd(300, 600, 10); // tonnes
	string etat <- "en_attente";
	string position <- "aller";
	string ligne_affectee;
	string destination_finale;
	point but;
	bool va_transiter <- false;
	string mission <- "premiere";
	int quantite <- 0;
	rgb couleur;
	bool dernier_transit_retour <- false;
	string situation <- "en_deplacement";
	int taille <- rnd(20, 30, 1);

	aspect default {
		draw square(taille) color: couleur;
	}

	reflex calcul_trajectoir {
		if (destination_finale = "Congo" and but != nil and affectation_aeroport = "France") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- france_congo_2.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- france_congo_3.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					but <- france_congo_3.location;
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		if (destination_finale != "Congo" and but != nil and affectation_aeroport = "France") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- france_chine_5.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- france_chine_6.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					list les_stations <- list(station) where ((each.nom = "Chine"));
					but <- any_location_in(les_stations[0]);
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					if (destination_finale = "Chine") {
						etat <- "chargement";
						//couleur<-#red;
						but <- nil;
						situation <- "arriver";
					} else {
						etat <- "transit";
						va_transiter <- true;
						but <- nil;
					}

				}

			}

		}

		if (destination_finale = "Australie" and but != nil and affectation_aeroport = "Chine") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- chine_australie_6.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- chine_australie_7.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					list les_stations <- list(station) where ((each.nom = "Australie"));
					but <- any_location_in(les_stations[0]);
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					etat <- "chargement";
					but <- nil;
					situation <- "arriver";
				}

			}

		}

		if (destination_finale != "Australie" and but != nil and affectation_aeroport = "Chine") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- france_chine_2.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- france_chine_1.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					if (destination_finale = "France") {
						etat <- "chargement";
						situation <- "arriver";
						but <- nil;
					} else {
						etat <- "transit";
						va_transiter <- true;
						but <- nil;
						mission <- "premier_transit";
					}

				}

			}

		}

		// pour ceux qui transitent
		if (destination_finale = "Congo" and but != nil and affectation_aeroport = "Chine" and va_transiter = true) {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premier_transit") {
					but <- france_congo_2.location;
					mission <- "deuxieme_transit";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme_transit") {
					but <- france_congo_3.location;
					mission <- "troisieme_transit";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme_transit") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "quatrieme_transit";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme_transit") {
					etat <- "chargement";
					but <- nil;
					situation <- "arriver";
				}

			}

		}

		//retour apres chargement de marchandise pour les avions de la chine
		if (destination_finale = "France" and but != nil and position = "retour" and affectation_aeroport = "Chine") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "premier_retour") {
					but <- france_chine_5.location;
					mission <- "deuxieme_retour";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme_retour") {
					but <- france_chine_6.location;
					mission <- "troisieme_retour";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme_retour") {
					list les_stations <- list(station) where ((each.nom = "Chine"));
					but <- any_location_in(les_stations[0]);
					mission <- "quatrieme_retour";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme_retour") {
					etat <- "dechargement";
					but <- nil;
					situation <- "arriver";
				}

			}

		}
		//retour pour la frane premier transit
		if (destination_finale = "Congo" and but != nil and position = "retour" and affectation_aeroport = "Chine") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "premier_retour") {
					but <- france_congo_5.location;
					mission <- "deuxieme_retour";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme_retour") {
					but <- france_congo_4.location;
					mission <- "troisieme_retour";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme_retour") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "quatrieme_retour";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme_retour") {
					etat <- "transit";
					but <- nil;
					situation <- "en_deplacement";
				}

			}

		}

		//retour en chine apres avoir passe par le congo via la france
		if (dernier_transit_retour = true and affectation_aeroport = "Chine") {
			if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_1") {
				but <- france_chine_5.location;
				mission <- "retour_dernier_transit_2";
			}

			if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_2") {
				but <- france_chine_6.location;
				mission <- "retour_dernier_transit_3";
			}

			if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_3") {
				list les_stations <- list(station) where ((each.nom = "Chine"));
				but <- any_location_in(les_stations[0]);
				mission <- "retour_dernier_transit_4";
			}

			if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_4") {
				etat <- "transit";
				//but <- nil;
				//situation<-"arriver";
			}

		}

		//Pour les avions francais qui veuleut rentrer apres avoir transiter par la chine pour aller en australie
		if (dernier_transit_retour = true and affectation_aeroport = "France") {
			if (but != nil) {
				if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_1") {
					but <- chine_australie_3.location;
					mission <- "retour_dernier_transit_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_2") {
					but <- chine_australie_2.location;
					mission <- "retour_dernier_transit_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_3") {
					but <- chine_australie_1.location;
					mission <- "retour_dernier_transit_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_4") {
					list les_stations <- list(station) where ((each.nom = "Chine"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_dernier_transit_5";
				}

				if (self distance_to but <= 6.0 and mission = "retour_dernier_transit_5") {
					etat <- "transit";
					but <- nil;
					//position<-"re";
					//situation<-"transit";
					mission <- "dernier_transit";
				}

			}

		}

		//pour les avions congolais qui veullent aller en france sans transiter
		if (destination_finale = "France" and but != nil and affectation_aeroport = "Congo") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- france_congo_5.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- france_congo_4.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}
		////pour les avions congolais qui veullent aller en chine via la france 
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "Congo") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- france_congo_5.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- france_congo_4.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "transit";
					situation <- "en_deplacement";
					va_transiter <- true;
					but <- nil;
				}

			}

		}

		////pour les avions congolais qui veullent aller en Australie
		if (destination_finale = "Australie" and but != nil and affectation_aeroport = "Congo") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- congo_australie_4.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- congo_australie_5.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					but <- congo_australie_6.location;
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					list les_stations <- list(station) where ((each.nom = "Australie"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions australiens qui veullent aller en congo sans transit 
		if (destination_finale = "Congo" and but != nil and affectation_aeroport = "Australie") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- congo_australie_2.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- congo_australie_1.location;
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "chargement";
					//situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions australiens qui veullent aller en france via le congo
		if (destination_finale = "France" and but != nil and affectation_aeroport = "Australie") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- congo_australie_2.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- congo_australie_1.location;
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "transit";
					va_transiter <- true;
					but <- nil;
				}

			}

		}

		////pour les avions australiens qui veullent aller en chine sans transit
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "Australie") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "premiere") {
					but <- chine_australie_3.location;
					mission <- "deuxieme";
				}

				if (self distance_to but <= 6.0 and mission = "deuxieme") {
					but <- chine_australie_2.location;
					mission <- "troisieme";
				}

				if (self distance_to but <= 6.0 and mission = "troisieme") {
					but <- chine_australie_1.location;
					mission <- "quatrieme";
				}

				if (self distance_to but <= 6.0 and mission = "quatrieme") {
					list les_stations <- list(station) where ((each.nom = "Chine"));
					but <- any_location_in(les_stations[0]);
					mission <- "cinquieme";
				}

				if (self distance_to but <= 6.0 and mission = "cinquieme") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions francais qui veullent rentrer en france apres avoir recupere la marchandise au congo
		if (destination_finale = "Congo" and but != nil and affectation_aeroport = "France") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- france_congo_5.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- france_congo_4.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions congolais qui veulent rentrer au congo apres avoir recupere la marchandise  en chine
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "Congo") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- france_chine_2.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- france_chine_1.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					etat <- "transit";
					mission <- "dernier_transit";
					but <- nil;
				}

			}

		}

		////pour les avions australiens qui veulent rentrer en australie apres avoir recupere la marchandise au en france
		if (destination_finale = "France" and but != nil and affectation_aeroport = "Australie") {
			if (but != nil) {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- france_congo_1.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- france_congo_2.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					but <- france_congo_3.location;
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_5";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_5") {
					mission <- "dernier_transit";
					//situation<-"transit";
					but <- nil;
				}

			}

		}

		////pour les avions australiens qui veulent rentrer en australie apres avoir recupere la marchandise au congo
		if (destination_finale = "Congo" and but != nil and affectation_aeroport = "Australie") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- congo_australie_4.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- congo_australie_5.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					but <- congo_australie_6.location;
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					list les_stations <- list(station) where ((each.nom = "Australie"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_5";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_5") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions congolais qui veulent rentrer  au congo apres avoir recupere la marchandise en france
		if (destination_finale = "France" and but != nil and affectation_aeroport = "Congo") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- france_congo_2.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- france_congo_3.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					etat <- "dechargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions chinois qui veulent rentrer  en chine apres avoir recupere la marchandise en australie sans transit
		if (destination_finale = "Australie" and but != nil and affectation_aeroport = "Chine") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- chine_australie_3.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- chine_australie_2.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					but <- chine_australie_1.location;
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					list les_stations <- list(station) where ((each.nom = "Chine"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_5";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_5") {
					etat <- "dechargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions chinois qui veulent rentrer  en chine apres avoir recupere la marchandise en australie sans transit
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "Australie") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- chine_australie_5.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- chine_australie_6.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					but <- chine_australie_7.location;
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					list les_stations <- list(station) where ((each.nom = "Australie"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_5";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_5") {
					etat <- "dechargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions congolais qui veulent rentrer  au congo apres avoir recupere la marchandise en australie sans transit
		if (destination_finale = "Australie" and but != nil and affectation_aeroport = "Congo") {
			if (position = "retour") {
				if (self distance_to but <= 6.0 and mission = "retour_premier_1") {
					but <- congo_australie_2.location;
					mission <- "retour_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_2") {
					but <- congo_australie_2.location;
					mission <- "retour_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_3") {
					list les_stations <- list(station) where ((each.nom = "Congo"));
					but <- any_location_in(les_stations[0]);
					mission <- "retour_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "retour_premier_4") {
					etat <- "dechargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions congolais qui veulent aller en chine  en passant par la france, transit
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "Congo") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "transit_premier_1") {
					but <- france_chine_5.location;
					mission <- "transit_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_2") {
					but <- france_chine_6.location;
					mission <- "transit_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_3") {
					list les_stations <- list(station) where ((each.nom = "Chine"));
					but <- any_location_in(les_stations[0]);
					mission <- "transit_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_4") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions australiens qui veulent aller en france  en passant par le congo, transit
		if (destination_finale = "France" and but != nil and affectation_aeroport = "Australie") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "transit_premier_1") {
					but <- france_congo_5.location;
					mission <- "transit_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_2") {
					but <- france_congo_4.location;
					mission <- "transit_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_3") {
					list les_stations <- list(station) where ((each.nom = "France"));
					but <- any_location_in(les_stations[0]);
					mission <- "transit_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_4") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions Francais qui veulent aller en australie  en passant par la chine, transit
		if (destination_finale = "Australie" and but != nil and affectation_aeroport = "France") {
			if (position = "aller") {
				if (self distance_to but <= 6.0 and mission = "transit_premier_1") {
					but <- chine_australie_6.location;
					mission <- "transit_premier_2";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_2") {
					but <- chine_australie_7.location;
					mission <- "transit_premier_3";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_3") {
					list les_stations <- list(station) where ((each.nom = "Australie"));
					but <- any_location_in(les_stations[0]);
					mission <- "transit_premier_4";
				}

				if (self distance_to but <= 6.0 and mission = "transit_premier_4") {
					etat <- "chargement";
					situation <- "arriver";
					but <- nil;
				}

			}

		}

		////pour les avions Francais qui veulent rentrer  apres avoir transiter par la chine
		if (destination_finale = "Australie" and but != nil and affectation_aeroport = "France") {

		//if (mission = "home") {
			if (self distance_to but <= 6.0 and mission = "home") {
				but <- france_chine_2.location;
				mission <- "home_1";
			}

			if (self distance_to but <= 6.0 and mission = "home_1") {
				but <- france_chine_1.location;
				mission <- "home_2";
			}

			if (self distance_to but <= 6.0 and mission = "home_2") {
				list les_stations <- list(station) where ((each.nom = "France"));
				but <- any_location_in(les_stations[0]);
				mission <- "home_3";
			}

			if (self distance_to but <= 6.0 and mission = "home_3") {
				etat <- "dechargement";
				situation <- "arriver";
				but <- nil;
				//}

			}

		}

		////pour les avions Congolais qui veulent rentrer  apres avoir transiter par la france
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "Congo") {

		//if (mission = "home") {
			if (self distance_to but <= 6.0 and mission = "home") {
				but <- france_congo_2.location;
				mission <- "home_1";
			}

			if (self distance_to but <= 6.0 and mission = "home_1") {
				but <- france_congo_3.location;
				mission <- "home_2";
			}

			if (self distance_to but <= 6.0 and mission = "home_2") {
				list les_stations <- list(station) where ((each.nom = "Congo"));
				but <- any_location_in(les_stations[0]);
				mission <- "home_3";
			}

			if (self distance_to but <= 6.0 and mission = "home_3") {
				etat <- "dechargement";
				situation <- "arriver";
				but <- nil;
				//}

			}

		}

		////pour les avions Francais qui veulent rentrer  apres avoir transiter par la chine
		if (destination_finale = "France" and but != nil and affectation_aeroport = "Australie") {

		//if (mission = "home") {
			if (self distance_to but <= 6.0 and mission = "home") {
				but <- congo_australie_4.location;
				mission <- "home_1";
			}

			if (self distance_to but <= 6.0 and mission = "home_1") {
				but <- congo_australie_5.location;
				mission <- "home_2";
			}

			if (self distance_to but <= 6.0 and mission = "home_2") {
				but <- congo_australie_6.location;
				mission <- "home_3";
			}

			if (self distance_to but <= 6.0 and mission = "home_3") {
				list les_stations <- list(station) where ((each.nom = "Australie"));
				but <- any_location_in(les_stations[0]);
				mission <- "home_4";
			}

			if (self distance_to but <= 6.0 and mission = "home_4") {
				etat <- "dechargement";
				situation <- "arriver";
				but <- nil;
				//}

			}

		}

		////pour les avions Francais qui veulent rentrer  sans avoir transite
		if (destination_finale = "Chine" and but != nil and affectation_aeroport = "France") {

		//if (mission = "home") {
			if (self distance_to but <= 6.0 and mission = "home_sans_transit") {
				but <- france_chine_2.location;
				mission <- "home_1";
			}

			if (self distance_to but <= 6.0 and mission = "home_1") {
				but <- france_chine_1.location;
				mission <- "home_2";
			}

			if (self distance_to but <= 6.0 and mission = "home_2") {
				list les_stations <- list(station) where ((each.nom = "France"));
				but <- any_location_in(les_stations[0]);
				mission <- "home_3";
			}

			if (self distance_to but <= 6.0 and mission = "home_3") {
				etat <- "dechargement";
				situation <- "arriver";
				but <- nil;
				//}

			}

		}

	}

	reflex dechargemnet_de_marchandise when: etat = "dechargement" {
	// l'avion commence à décharger la marchandise qu'il a transportée
		quantite <- quantite - vitesse_de_chargement;
		if (quantite <= 0) {
		// l'avion doit payer les frais de l'aeroport avant de prendre un autre vol
			int montant_total <- taux_par_quantite * capacite_marchandise_transporter;
			// l'aeroport va prendre 10 pour cent sur la recette de l'avion
			float montant_a_payer <- (montant_total * 10) / 100;
			list<tour_controle> le_tour;
			if (destination_finale = "France") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_france"));
			}

			if (destination_finale = "Chine") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_chine"));
			}

			if (destination_finale = "Australie") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_australie"));
			}

			if (destination_finale = "Congo") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_congo"));
			}

			tour_controle Tour_controle <- le_tour[0];
			Tour_controle.revenu_pour_aeroport <- Tour_controle.revenu_pour_aeroport + montant_a_payer;
			// On initialise l'agent
			etat <- "en_attente";
			position <- "aller";
			va_transiter <- false;
			mission <- "premiere";
			quantite <- 0;
			dernier_transit_retour <- false;
			situation <- "en_deplacement";
		}

	}

	reflex chargement_de_marchandise when: etat = "chargement" {
		quantite <- quantite + vitesse_de_chargement;
		// l'avion commence à charger la marchandise qu'il va transporter
		if (quantite >= capacite_marchandise_transporter) { // 100  
			int montant_total <- taux_par_quantite * quantite;
			// l'avion doit payer les frais de l'aeroport avant de prendre un autre vol
			float montant_a_payer <- (montant_total * 10) / 100;
			list<tour_controle> le_tour;
			if (destination_finale = "France") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_france"));
			}

			if (destination_finale = "Chine") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_chine"));
			}

			if (destination_finale = "Australie") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_australie"));
			}

			if (destination_finale = "Congo") {
				le_tour <- list(tour_controle) where ((each.nom = "tour_de_controle_congo"));
			}

			tour_controle Tour_controle <- le_tour[0];
			Tour_controle.revenu_pour_aeroport <- Tour_controle.revenu_pour_aeroport + montant_a_payer;
			etat <- "plein";
			position <- "retour";
			// Il change la couleur quand il termine à charger la marchandise
			//couleur<-#blue;
			situation <- "en_deplacement";
			mission <- "premier_retour";
			if (destination_finale = "France" and affectation_aeroport = "Congo") {
			}

		}

	}

	reflex aller {
		do goto target: but speed: 3.1;
		if (destination_finale = "Congo" and va_transiter = true and but = nil) {
		}

	}

}

species tour_controle {
	string nom;
	bool deja_affecter <- false;
	int comptage <- 100;
	rgb couleur <- #green;
	float revenu_pour_aeroport <- 0.0;
	int rayon_observation <- 300;

	aspect default {
		draw circle(20) color: #yellow;
		draw triangle(30) color: couleur;
	}

	reflex coordination_des_avions {
		if (nom = "tour_de_controle_france") {
			write "Le revenu pour aeroport de la France est de: " + revenu_pour_aeroport + " VND";
			comptage <- comptage + 1;
			if (comptage >= 99) {
				list<avion> les_avions <- list(avion) where ((each.but = nil) and (each distance_to self <= rayon_observation) and each.situation = "en_deplacement");
				int nb <- length(les_avions);
				if (les_avions != []) {
					avion Avion <- les_avions[rnd(nb - 1)];
					Avion.etat <- "aller_decoller";
					if (Avion.destination_finale = "Congo" and Avion.va_transiter = false) {
						Avion.but <- france_congo_1.location;
					} else if (Avion.destination_finale = "Chine" and Avion.va_transiter = false) {
						Avion.but <- france_chine_4.location;
					} else if (Avion.destination_finale = "Australie" and Avion.va_transiter = false) {
						Avion.but <- france_chine_4.location;
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "Chine") {
						Avion.but <- france_congo_1.location;
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Chine") {
						Avion.but <- france_chine_4.location;
						Avion.mission <- "premier_retour";
					} else if (Avion.va_transiter = true and Avion.position = "retour" and Avion.affectation_aeroport = "Australie") {
						Avion.but <- france_congo_1.location;
						Avion.mission <- "retour_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "retour" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- france_congo_1.location;
						Avion.mission <- "home";
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- france_congo_1.location;
						Avion.mission <- "retour_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- france_chine_4.location;
						Avion.mission <- "transit_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "retour") {
						Avion.but <- france_chine_4.location;
						Avion.dernier_transit_retour <- true;
						Avion.mission <- "retour_dernier_transit_1";
					} }

				comptage <- 0;
			} }

		if (nom = "tour_de_controle_chine") {
			write "Le revenu pour aeroport de la Chine est de: " + revenu_pour_aeroport + " VND";
			comptage <- comptage + 1;
			if (comptage >= 99) {
				list<avion> les_avions <- list(avion) where ((each.but = nil) and (each distance_to self <= rayon_observation) and each.situation = "en_deplacement");
				int nb <- length(les_avions);
				if (les_avions != []) {
					avion Avion <- les_avions[rnd(nb - 1)];
					Avion.etat <- "aller_decoller";
					if (Avion.destination_finale = "France" and Avion.va_transiter = false) {
						Avion.but <- france_chine_3.location;
					} else if (Avion.destination_finale = "Australie" and Avion.va_transiter = false) {
						Avion.but <- chine_australie_5.location;
					} else if (Avion.destination_finale = "Congo" and Avion.va_transiter = false) {
						Avion.but <- france_chine_3.location;
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "France") {
						Avion.but <- chine_australie_5.location;
						Avion.mission <- "transit_premier_1";
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "France") {
						Avion.but <- france_chine_3.location;
						Avion.mission <- "home_sans_transit";
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Australie") {
						Avion.but <- chine_australie_5.location;
						Avion.mission <- "retour_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "Australie") {
						Avion.but <- france_chine_3.location;
						Avion.mission <- "transit_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "retour" and Avion.affectation_aeroport = "France" and Avion.mission = "dernier_transit") {
						Avion.but <- france_chine_3.location;
						Avion.mission <- "home";
					} else if (Avion.va_transiter = true and Avion.position = "retour" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- france_chine_3.location;
						Avion.mission <- "retour_premier_1";
					} }

				comptage <- 0;
			} }

		if (nom = "tour_de_controle_australie") {
			write "Le revenu pour aeroport de l'Australie est de: " + revenu_pour_aeroport + " VND";
			comptage <- comptage + 1;
			if (comptage >= 99) {
				list<avion> les_avions <- list(avion) where ((each.but = nil) and (each distance_to self <= rayon_observation) and each.situation = "en_deplacement");
				int nb <- length(les_avions);
				if (les_avions != []) {
					avion Avion <- les_avions[rnd(nb - 1)];
					Avion.etat <- "aller_decoller";
					if (Avion.destination_finale = "Congo" and Avion.va_transiter = false) {
						Avion.but <- congo_australie_3.location;
					} else if (Avion.destination_finale = "Chine" and Avion.va_transiter = false) {
						Avion.but <- chine_australie_4.location;
					} else if (Avion.destination_finale = "France" and Avion.va_transiter = false) {
						Avion.but <- congo_australie_3.location;
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "Chine") {
					//Avion.but <- france_congo_1.location;
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- congo_australie_3.location;
						Avion.mission <- "retour_premier_1";
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Chine") {
						Avion.but <- chine_australie_4.location;
						Avion.mission <- "retour_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- france_chine_4.location;
						Avion.mission <- "transit_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "retour" and Avion.affectation_aeroport = "France") {
						Avion.but <- chine_australie_4.location;
						Avion.dernier_transit_retour <- true;
						Avion.mission <- "retour_dernier_transit_1";
					} }

				comptage <- 0;
			} }

		if (nom = "tour_de_controle_congo") {
			write "Le revenu pour aeroport du Congo est de: " + revenu_pour_aeroport + " VND";
			comptage <- comptage + 1;
			if (comptage >= 99) {
				list<avion> les_avions <- list(avion) where ((each.but = nil) and (each distance_to self <= rayon_observation) and each.situation = "en_deplacement");
				int nb <- length(les_avions);
				if (les_avions != []) {
					avion Avion <- les_avions[rnd(nb - 1)];
					Avion.etat <- "aller_decoller";
					if (Avion.destination_finale = "France" and Avion.va_transiter = false) {
						Avion.but <- france_congo_6.location;
					} else if (Avion.destination_finale = "Australie" and Avion.va_transiter = false) {
						Avion.but <- congo_austalie_7.location;
					} else if (Avion.destination_finale = "Chine" and Avion.va_transiter = false) {
						Avion.but <- france_congo_6.location;
					} else if (Avion.va_transiter = true and Avion.position = "retour" and Avion.affectation_aeroport = "Australie" and Avion.mission = "dernier_transit") {
						Avion.but <- congo_austalie_7.location;
						Avion.mission <- "home";
					} else if (Avion.va_transiter = true and Avion.position = "retour") {
						Avion.but <- france_congo_6.location;
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Congo") {
						Avion.but <- france_congo_6.location;
						Avion.mission <- "retour_premier_1";
					} else if (Avion.va_transiter = true and Avion.position = "aller" and Avion.affectation_aeroport = "Australie") {
						Avion.but <- france_congo_6.location;
						Avion.mission <- "transit_premier_1";
					} else if (Avion.va_transiter = false and Avion.position = "retour" and Avion.affectation_aeroport = "Australie") {
						Avion.but <- congo_austalie_7.location;
						Avion.mission <- "retour_premier_1";
					} }

				comptage <- 0;
			} } } }

experiment Aerien type: gui {
	float minimum_cycle_duration <- 0.04;
	output {
		display map type: opengl {
			image "../includes/Map.png";
			species airport transparency: 0.5;
			species station transparency: 0.8;
			species route;
			species avion;
			species tour_controle;
			graphics "sortie" refresh: false {
//				draw circle(10) at: france_chine_1 color: #red;
//				draw circle(10) at: france_chine_2 color: #red;
//				draw circle(10) at: france_chine_3 color: #red;
//				draw circle(10) at: france_chine_4 color: #red;
//				draw circle(10) at: france_chine_5 color: #red;
//				draw circle(10) at: france_chine_6 color: #red;
//				draw circle(10) at: chine_australie_1 color: #red;
//				draw circle(10) at: chine_australie_5 color: #red;
//				draw circle(10) at: chine_australie_2 color: #red;
//				draw circle(10) at: chine_australie_3 color: #red;
//				draw circle(10) at: chine_australie_4 color: #red;
//				draw circle(10) at: chine_australie_7 color: #red;
//				draw circle(10) at: chine_australie_6 color: #red;
//				draw circle(10) at: congo_australie_6 color: #red;
//				draw circle(10) at: congo_australie_2 color: #red;
//				draw circle(10) at: congo_australie_5 color: #red;
//				draw circle(20) at: congo_australie_3 color: #red;
//				draw circle(10) at: congo_austalie_7 color: #red;
//				draw circle(10) at: france_congo_1 color: #red;
//				draw circle(10) at: france_congo_2 color: #red;
//				draw circle(10) at: france_congo_3 color: #red;
//				draw circle(10) at: france_congo_6 color: #red;
//				draw circle(10) at: france_congo_5 color: #red;
//				draw circle(10) at: congo_australie_1 color: #red;
//				draw circle(10) at: chine_australie_2 color: #red;
//				draw circle(10) at: france_congo_4 color: #red;
//				draw circle(10) at: chine_australie_4 color: #red;
//				draw circle(10) at: chine_australie_5 color: #red;
//				draw circle(10) at: congo_australie_4 color: #red;
			}

		}

	}

}

