import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *  Groupe        : Vendredi
 *
 * La classe Schema
 **/
public class EXO5 {
    
    /* les attributs */
    
    String server = "db-oracle.ufr-info-p6.jussieu.fr";
    String port = "1521";
    String database = "oracle";
    String user = "E1234567";            // votre login
    String password = "E1234567";         // le mot de passe (=login)

    Connection connexion1 = null;
    Connection connexion2 = null;
    static PrintStream out = System.out;    // affichage des résulats à l'ecran
    
    /**
     * methode main: point d'entrée
     **/
    public static void main(String param[]) {

        /* initialisation */
       	EXO5 c = new EXO5();
        
	/* requete */
	c.traiteRequete();
    }
    
    /**
     * Constructeur : initialisation
     **/
    private EXO5(){
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
    public void traiteRequete() {
        try {

	    /* à compléter */

	    String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
	    out.println("Connexion avec l'URL: " + url);
	    out.println("utilisateur: " + user + ", mot de passe: " + password);
            connexion1 = DriverManager.getConnection(url, user, password);
            connexion2 = DriverManager.getConnection("jdbc:oracle:thin:@oracle.ufr-info-p6.jussieu.fr:1521:ora10",user,password);
            
            // R1: "SELECT Joueur.NOM,Sponsor.NATIONALITE FROM Joueur INNER JOIN SPONSOR where Joueur.NATIONALITE = Sponsor.NATIONALITE"
            // R2: "SELECT Joueur.NOM, Joueur.NATIONALITE FROM JOUEUR"
            Statement lecture = connexion1.createStatement();
      
            
            ResultSet resultat = lecture.executeQuery("SELECT DISTINCT T1.Nom, T1.Nationalite, T2.Sponsor FROM JOUEUR T1 INNER JOIN GAIN T2 ON T1.NuJoueur = T2.NuJoueur ORDER BY T1.Nom ");
            ResultSet resultatSponsor;
 
           PreparedStatement lectureSponsor = connexion2.prepareStatement("SELECT NOM, NATIONALITE FROM SPONSOR WHERE NOM=?");
            
             
             
	    out.println("resultat...");
	    int card = 0;
	   
            while (resultat.next()) {
            
            	lectureSponsor.setString(1,resultat.getString(3));
            	resultatSponsor = lectureSponsor.executeQuery();
            	while(resultatSponsor.next())
            	{
       				//out.println(resultat.getString(1)+", " + resultat.getString(2)+" , " + resultatSponsor.getString(1) + " , "  + resultatSponsor.getString(2));
            		
            	}
            	
            	//out.println(resultat.getString(1)+", " + resultat.getString(2)+" , "   );
            	//out.println(resultat.getString(1));
                card++;
            }
            out.println( ""+card); 
	    resultat.close();
	    connexion1.close();


        }

        /* getion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion1, e);}
    }
}
