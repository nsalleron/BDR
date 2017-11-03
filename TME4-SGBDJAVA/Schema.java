import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *  Groupe        : Vendredi
 *
 * La classe Schema
 **/
public class Schema {
    
    /* les attributs */
    
    String server = "db-oracle.ufr-info-p6.jussieu.fr";
    String port = "1521";
    String database = "oracle";
    String user = "E1234567";            // votre login
    String password = "E1234567";         // le mot de passe (=login)

    Connection connexion = null;
    static PrintStream out = System.out;    // affichage des résulats à l'ecran
    
    /**
     * methode main: point d'entrée
     **/
    public static void main(String param[]) {

	if (param.length == 0) {
	    throw new RuntimeException("Pas de  requete, arret immediat");
	}


	/* requete */
	String requete = param[0];
	out.println("La requete est " + requete);

        /* initialisation */
       	Schema c = new Schema();
        
	/* requete */
	c.traiteRequete(requete);
    }
    
    /**
     * Constructeur : initialisation
     **/
    private Schema(){
        try {

            /* Chargement du pilote JDBC */
	    /* driver Oracle */
	    Class.forName("oracle.jdbc.driver.OracleDriver");
        }
        catch(Exception e) {
            Outil.erreurInit(e);
        }
    }
    
    
    /**
     *  La methode traiteRequete
     *  affiche le resultat d'une requete
     */
    public void traiteRequete(String requete) {
        try {

	    /* à compléter */

	    String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
	    out.println("Connexion avec l'URL: " + url);
	    out.println("utilisateur: " + user + ", mot de passe: " + password);
            connexion = DriverManager.getConnection(url, user, password);
            
	    /* Commentaire: récupération de l'objt statement, exécution, affichage */
            DatabaseMetaData databaseMeta = connexion.getMetaData();
            
	    //out.println("execute la requete : " + requete);
            ResultSet resultat = databaseMeta.getColumns(requete,"%",requete,"%");
	    //ResultSetMetaData meta = resultat.getMetaData();
	    
         
	    out.println("resultat...");
	    out.println("NOM \t\t TYPE");
	    out.println("-------------------------------------------------");
            while (resultat.next()) {
            
                String tuple = resultat.getString("COLUMN_NAME")+"\t\t"+resultat.getString("TYPE_NAME");
                out.println(tuple);
            }
	    resultat.close();
	    connexion.close();


        }

        /* getion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
