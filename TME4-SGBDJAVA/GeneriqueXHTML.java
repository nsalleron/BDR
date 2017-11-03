import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : Salleron
 *  Groupe        : Vendredi
 *
 * La classe Generique
 **/
public class GeneriqueXHTML {
    
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
	//	out.println("La requete est " + requete);

        /* initialisation */
        GeneriqueXHTML c = new GeneriqueXHTML();
        
	/* requete */
	c.traiteRequete(requete);
    }
    
    /**
     * Constructeur : initialisation
     **/
    private GeneriqueXHTML(){
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
	    //out.println("Connexion avec l'URL: " + url);
	    // out.println("utilisateur: " + user + ", mot de passe: " + password);
            connexion = DriverManager.getConnection(url, user, password);
            
	    /* Commentaire: récupération de l'objt statement, exécution, affichage */
            Statement lecture =  connexion.createStatement();
	    
            
	    //out.println("execute la requete : " + requete);
            ResultSet resultat = lecture.executeQuery(requete);
	    ResultSetMetaData meta = resultat.getMetaData();



	    
	    out.println("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>");
	    out.println("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html>\n<head> <title>Resultat </title> </head>\n<body> ");
	    out.println("<h3> La requete est : </h3> " + requete );
	    out.println("<h3> Le resultat est : </h3>");
	    out.println("<table border=\"2\">");
            
	    //out.println("resultat...");
	    StringBuffer column = new StringBuffer("");
	    out.print("<tr><th> NUMERO </th>");
	    for(int i = 1;i<meta.getColumnCount()+1;i++){
		column.append("<th>"+meta.getColumnName(i)+"</th>");
	    }
	    column.append("</tr>");
	    out.println(column.toString());
	    
	    int j =1;
            while (resultat.next()) {
		out.print("<tr>");
                String tuple = "<tr><td>"+j+"</td><td>"+ resultat.getString(1) + "</td><td>" + resultat.getString(2)  + "</td><td>" + resultat.getString(3)  + "</td><td>" + resultat.getString(4) + "</td><td>" + resultat.getString(5) + "</td></tr>";
                out.println(tuple);
		j++;
            }

	    out.println("</table");
	    out.println("</body>");
	    out.println("</html>");
	    resultat.close();
	    lecture.close();
	    connexion.close();


        }

        /* getion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
