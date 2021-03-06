import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *  Groupe        : Vendredi
 *
 * La classe Generique
 **/
public class Generique {
    
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
        Generique c = new Generique();
        
	/* requete */
	c.traiteRequete(requete);
    }
    
    /**
     * Constructeur : initialisation
     **/
    private Generique(){
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
            Statement lecture =  connexion.createStatement();
	    
            
	    out.println("execute la requete : " + requete);
            ResultSet resultat = lecture.executeQuery(requete);
	    ResultSetMetaData meta = resultat.getMetaData();
	    
            
	    out.println("resultat...");
	    StringBuffer column = new StringBuffer("");
	    for(int i = 1;i<meta.getColumnCount()+1;i++){
		column.append(meta.getColumnName(i)+"\t");
	    }
	    column.append("\n -------------------------------------------------");
	    out.println(column.toString());
	    
	    
            while (resultat.next()) {
                String tuple = resultat.getString(1) + "\t" + resultat.getString(2)  + "\t" + resultat.getString(3)  + "\t" + resultat.getString(4) + "\t" + resultat.getString(5);
                out.println(tuple);
            }
	    resultat.close();
	    lecture.close();
	    connexion.close();


        }

        /* getion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
