import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *
 *
 * La classe Joueur
 **/
public class Joueur {
    
    /* Commentaire: */
    
    String server = "db-oracle.ufr-info-p6.jussieu.fr";
    String port = "1521";
    String database = "oracle";
    String user = "E1234567";
    String password = "E1234567";
    String requete = "select nom, prenom from Joueur2";

    Connection connexion = null;
    public static PrintStream out = System.out;    // affichage des résulats à l'ecran
    
    /**
     * methode main: point d'entrée
     **/
    public static void main(String a[]) {

        /* Commentaire: On instancie la classe Joueur...*/
        Joueur c = new Joueur();
        
	c.traiteRequete();
    }
    
    /**
     * Constructeur : initialisation
     **/
    protected Joueur(){
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
     *  Commentaire : voir si dessous
     *
     */
    public void traiteRequete() {
        try {

            /* Commentaire: On commence par effectuer une connexion au serveur. */
	    String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
            connexion = DriverManager.getConnection(url, user, password);
            
            /* Commentaire: Création d'un object Statement qui sera utilisé pour réaliser la requête. */
            Statement lecture =  connexion.createStatement();
            
            /* Commentaire: On exécute la requête prédéfinie*/
            ResultSet resultat = lecture.executeQuery(requete);
            
            /* Commentaire: Pour chaque ligne, on imprime le tuple. */
            while (resultat.next()) {
                String tuple = resultat.getString(1) + "\t" + resultat.getString(2);
                out.println(tuple);
            }

            /* Commentaire: Fermeture de la connexion*/
	    resultat.close();
	    lecture.close();
	    connexion.close();
        }

        /* Commentaire: en cas de problème durant la connexion ou exécution de la requête. */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
