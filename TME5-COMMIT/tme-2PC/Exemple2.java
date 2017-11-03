/*


NOM1:
Prenom1:

NOM2:
Prenom2:


*/


import eduni.simjava.*;
import eduni.simjava.distributions.*;
import eduni.simanim.*;


/**
 *   Les messages 
 */
class M {
  static final String PREPARE = "prepare";
  static final String VOTE_COMMIT = "vote commit";
  static final String VOTE_ABORT = "vote abort";

  static final String COMMIT = "commit";
  static final String ABORT = "abort";

  static final String OK = "ok";
  static final String ERREUR = "erreur";

  static final String TIMEOUT = "timeout";
}


/**
 *  APPLICATION CLIENTE
 */
class AppliCliente extends Entite {

  AppliCliente(String name, int x, int y, String image){
    super(name, image, x, y);
  }

  public void body() {
    try {
      
      while (Sim_system.running()) {
	
	/* lancer la validation */
	envoyer_message("Coord", M.COMMIT);
	
	/* attendre la fin de la validation */
	String reponse = attendre_message().contenu();
	System.out.println("Appli cliente a reçu : " + reponse);
      }
    }
    catch(Exception e) {
      System.out.println("Fin de l'entite " + get_name());
    }
  }
}


/**
 *  COORDINATEUR
 */
class Coordinateur extends Entite {
  private Sim_stat stat;

  Coordinateur(String name, int x, int y, String image) {
    super(name, image, x, y);
  }

  public void body() {

    String m = null;
    
    try {      
      while (Sim_system.running()) {
	m = attendre_message().contenu();

	/* phase 1 : demander aux participants de se preparer*/
	envoyer_message("Participant1", M.PREPARE);
	envoyer_message("Participant2", M.PREPARE);
		
	/* attendre le vote des participants */
	boolean decision_valider = true;
	for (int i = 0; i < 2; i++) {
	  m = attendre_message().contenu();
	  System.out.println("Coord a reçu " + m);
	  
	  if(m == M.VOTE_ABORT) {	  
	    decision_valider = false;
	  }
	}
	
	/* phase 2 */
	String decision = (decision_valider ? M.COMMIT : M.ABORT);
	envoyer_message("Participant1", decision);
	envoyer_message("Participant2", decision);
		
	/* attendre la reponse finale des participants */
	for (int i=0; i<2; i++) {
	  m = attendre_message().contenu();
	  System.out.println("Coord a reçu " + m);
	}
	
	/* repondre à l'application */
	String reponse = (decision_valider ? M.OK : M.ERREUR);
	envoyer_message("AppliCliente", reponse);
      }
    }
    catch(Exception e) {
      System.out.println("Fin de l'entite " + get_name());
    }
  }
}


/**
 *   PARTICIPANT
 */
class Participant extends Entite {
  private Sim_uniform_obj duree, abort ;
  private boolean panne;

  Participant(String name, int x, int y, String image, boolean panne) {
    super(name, image, x, y);
    this.panne = panne;

    /* la duree dans [90,110] */
    duree = new Sim_uniform_obj("Duree", 90, 110);
    add_generator(duree);

    abort = new Sim_uniform_obj("Abort", 1, 100);
    add_generator(abort);
  }

  public void body() {

    /* le pourcentage d'abandon */
    int TAUX_ABORT = 30;

    try {
      while (Sim_system.running()) {

	/* Etape1 : le participant attend que le coordinateur lui demande de se préparer*/
	String m = attendre_message().contenu();

	System.out.println("Participant a reçu " + m);
	verifier_message(m, M.PREPARE);

	/* le participant se prepare a voter */
	sim_process(duree.sample());
	String vote = ( abort.sample() > TAUX_ABORT ? M.VOTE_COMMIT : M.VOTE_ABORT );

	/* envoyer le vote */
	envoyer_message("Coord", vote);

	/* Etape 2 : le participant attend la décision du coordinateur */
	m = attendre_message().contenu();
	  
	envoyer_message("Coord", M.OK);
      }
    }
    catch(Exception e) {
      System.out.println("Fin de l'entite " + get_name());
    }
  }
}


/**
   Une entite
   
*/
class Entite extends Sim_entity {
  Entite(String name, String image, int x, int y) {
    super(name, image, x, y);
    setName(name);
  }

  protected Message attendre_message() throws Exception {      
    Sim_event e = new Sim_event();
    sim_get_next(e);  
    Message m = (Message) e.get_data();
    if (m == null) {
      throw new Exception("fin");
    }
    else {
      sim_completed(e);
      return m;
    }
  }

  /**
     A
   */
  protected Message attendre_message_timeout(int timeout) throws Exception {      
    Sim_event e = new Sim_event();
    double restant = sim_wait_for(timeout, e);  
    Message m = (Message) e.get_data();
    if(restant == 0) {
      return new Message(null, M.TIMEOUT);
    }	
    else if (m == null) {
      throw new Exception("fin");
    }
    else {
      sim_completed(e);
      return m;
    }
  }

  protected void envoyer_message(String port, String message) {
    Message m = new Message(get_name(), message);
    sim_schedule(port, 0, 1, m);
    sim_trace(1, "S " + port + " " + message);
  }

  /* verifier si le message recu correspond au message attendu */
  protected void verifier_message(String m, String prevu) {
    if (m != prevu) {
      System.out.println("Erreur : reception d'un message innatendu '" + m + "'. Le message aurait du etre " + prevu);
      System.exit(0);
    }
  }


  /* se mettre en panne pendant le temps t*/
  protected void panne( int t) {
    sim_pause(t);
    vider_messages_recus();
  }

  /* vider la file des message recus */
  protected void vider_messages_recus() {
    Sim_event e = new Sim_event();
    while(sim_waiting() > 0) {
      sim_get_next(e);
    }
  }


  /* la date actuelle de simulation */
  protected double date() {
    return Sim_system.sim_clock();
  }


}
  

class Message {
  String expediteur;
  String contenu;

  Message(String expediteur, String contenu){
    this.expediteur = expediteur.intern();
    this.contenu = contenu.intern();
  }
  String contenu(){ return contenu;}
  String expediteur(){ return expediteur;}

}

/*
  Le simulateur
*/
public class Exemple1 extends Anim_applet {

  public void anim_layout() {
    
    /* creer les entites */


    /* creer l'appli cliente */
    AppliCliente app = new AppliCliente("AppliCliente", 10, 60, "client");
    app.add_port(new Sim_port("Coord", "port", Anim_port.RIGHT, 40));

    /* creer le coordinateur */
    Coordinateur coord = new Coordinateur("Coord", 140, 60, "coord");
    coord.add_port(new Sim_port("AppliCliente", "port", Anim_port.LEFT, 40));
    coord.add_port(new Sim_port("Participant1", "port", Anim_port.RIGHT, 20));
    coord.add_port(new Sim_port("Participant2", "port", Anim_port.RIGHT, 60));

    /* creer le participant 1 */
    Participant p1 = new Participant("Participant1", 370, 10, "base1", false);
    p1.add_port(new Sim_port("Coord", "port", Anim_port.LEFT, 40));

    /* creer le participant 2 */
    Participant p2 = new Participant("Participant2", 370, 110, "base2", false);
    p2.add_port(new Sim_port("Coord", "port", Anim_port.LEFT, 40));


    /* relier les entites */
    Sim_system.link_ports("AppliCliente", "Coord", "Coord", "AppliCliente");
    Sim_system.link_ports("Coord", "Participant1", "Participant1", "Coord");
    Sim_system.link_ports("Coord", "Participant2", "Participant2", "Coord");
  }

  public void sim_setup() {
    /* terminer la simulation après N transactions */
    int nb_transactions = 4;
    Sim_system.set_termination_condition(Sim_system.EVENTS_COMPLETED, "AppliCliente", 1, nb_transactions, false);
  }

}
