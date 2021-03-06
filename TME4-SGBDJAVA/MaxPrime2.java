import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *  Groupe        : Vendredi
 *
 * La classe MaxPrime permet de récupérer directement à partir d'une base de données les primes correspondant à une année particulière définit en entrée, pendant l'exécution du programme. 
 **/
public class MaxPrime2 {

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
        MaxPrime2 c = new MaxPrime2();
	c.traiteRequete();
    }
 
   
    /**
     * Constructeur : initialisation
     **/
    private MaxPrime2(){
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
	    String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
	    out.println("Connexion avec l'URL: " + url);
	    out.println("utilisateur: " + user + ", mot de passe: " + password);
            connexion = DriverManager.getConnection(url, user, password);
            
            
	    //connexion.setAutoCommit(false);
	    out.println("statement...");
	     String requete = "select nom, max(prime) from Gain2 g, Joueur2 j"
	    + " where g.nujoueur = j.nujoueur and annee = ?"  + " group by nom";
	     PreparedStatement lecture = connexion.prepareStatement(requete);
	    
	    
	    while(true){
		 /* Commentaire: Lecture d'une valeur sur l'entrée std*/
		String a1 = Outil.lireValeur("Saisir une annee");
		if(a1.length() == 0)
		    break;
	
            
		/* Commentaire: récupération de l'objt statement, exécution, affichage */
		lecture.setInt(1,Integer.parseInt(a1));
		lecture.executeUpdate();
	
		resultat = lecture.executeQuery(requete);
            
		out.println("resultat...");
		while (resultat.next()) {
		    String tuple = resultat.getString(1) + "\t" + resultat.getString(2);
		    out.println(tuple);
		}
		resultat.close();
	    }
	   
	   
	    lecture.close();
	    connexion.close();
        }

        /* gestion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
