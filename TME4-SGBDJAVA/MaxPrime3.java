import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *  Groupe        : Vendredi
 *
 * La classe MaxPrime permet de récupérer directement à partir d'une base de données les primes correspondant à une année particulière définit en entrée, pendant l'exécution du programme. 
 **/
public class MaxPrime3 {

    String server = "db-oracle.ufr-info-p6.jussieu.fr";
    String port = "1521";
    String database = "oracle";
    String user = "E1234567";            // votre login
    String password = "E1234567";         // le mot de passe
    Connection connexion = null;
    public static PrintStream out = System.out;    // affichage des résulats à l'ecran

    /**
     * methode main: point d'entrée
     **/
    public static void main(String a[]) {
        MaxPrime3 c = new MaxPrime3();
	c.traiteRequete();
    }
 
   
    /**
     * Constructeur : initialisation
     **/
    private MaxPrime3(){
        try {

            /* Chargement du pilote JDBC */
	    Class.forName("oracle.jdbc.driver.OracleDriver");
        }
        catch(Exception e) {
            Outil.erreurInit(e);
        }
    }
    
    
    /**
     *  La methode traiteRequete
     *  
     */
    public void traiteRequete() {
        try {
        
	    ResultSet resultat = null;
	    ResultSet resultatPays = null;
	    
	    String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
	    out.println("Connexion avec l'URL: " + url);
	    out.println("utilisateur: " + user + ", mot de passe: " + password);
	    
            connexion = DriverManager.getConnection(url, user, password);
	    //connexion.setAutoCommit(false);
	    out.println("statement...");
	    
	    String requete = "select nom, max(prime) from Gain2 g, Joueur2 j"
	    + " where g.nujoueur = j.nujoueur and j.nationalite = ?"  + " group by nom";
	    
	    PreparedStatement joueurMax = connexion.prepareStatement(requete);
	    joueurMax.setMaxRows(1);
	    
	    Statement pays = connexion.createStatement();
	    
	    while(true){
	    
		 /* Commentaire: Lecture d'une valeur sur l'entrée std*/
		String requetePays = "select distinct nationalite from Joueur2 order by nationalite";
		if(Outil.lireValeur("Confirmation : ").length() != 0)
		    break;
		
		/* Commentaire: récupération de l'objt statement, exécution, affichage */
		resultatPays = pays.executeQuery(requetePays);
		out.println("resultat...");
		while(resultatPays.next()){
		    
		    joueurMax.setString(1,resultatPays.getString(1));
		    joueurMax.executeUpdate();
		    
		    resultat = joueurMax.executeQuery(requete);
		    
		    while (resultat.next()) {
		    
			out.println("Nationalite = "+resultatPays.getString(1));
			
			    out.println("JOUEUR | MAX PRIME");
			    String tuple = resultat.getString(1) + "\t" + resultat.getString(2);
			    out.println(tuple);
			}
		    
		}
		
		resultatPays.close();
		resultat.close();
		
	    }
	    joueurMax.close();
	    pays.close();
	    connexion.close();
        }
	

        /* gestion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
