/*
TME 2PC

NOM1:
Prenom1:

NOM2:
Prenom2:

Numéro de binome: 

*/


import eduni.simjava.*;
import eduni.simjava.distributions.*;
import eduni.simanim.*;
import java.util.*;


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

  static final String REPRISE = "reprise apres panne";

  static final String TIMEOUT = "timeout";
}


/**
 *  APPLICATION CLIENTE
 *  ===================
 */
class AppliCliente extends Entite {
  private Sim_uniform_obj duree;

  AppliCliente(String name, int x, int y, String image){
    super(name, image, x, y);

    /* la duree d'une transaction est comprise dans [200, 250] */
    duree = new Sim_uniform_obj("Duree", 200, 250);
    add_generator(duree);
  }

  public void body() {
    try {
      
      while (Sim_system.running()) {
	
	/* l'application traite une nouvelle transaction pendant un certain temps */
	sim_process(duree.sample());

	/* puis l'application demande la validation de la transaction*/
	envoyer_message("Coord", M.COMMIT);
	
	/* attend la fin de la validation */
	String reponse = attendre_message().contenu();
	System.out.println("Appli cliente a reçu : " + reponse);
      }
    }
    catch(Exception e) {
      exception(e);
    }
  }
}


/**
 *  COORDINATEUR
 *  ============
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
	envoyer_message("Participant3", M.PREPARE);	
	/* attendre le vote des participants */
	boolean decision_valider = true;
	for (int i = 0; i < 3; i++) {
 	   
 	  
	   m = attendre_message_timeout(300).contenu();
	   System.out.println(m);
	   if(m.equals("timeout")){
	   	System.out.println("TIMEOUT");
	   	decision_valider = false;
	   }
	   
	  //m = attendre_message().contenu();
	  System.out.println("Coord a reçu " + m);
	  
	  /* décider d'abandonner la transaction des qu'il y a au moins un "vote abort" */
	  if(m == M.VOTE_ABORT) {	  
	    decision_valider = false;
	  }
	}
	
	/* phase 2 */
	String decision = (decision_valider ? M.COMMIT : M.ABORT);
	envoyer_message("Participant1", decision);
	envoyer_message("Participant2", decision);
	envoyer_message("Participant3", decision);
		
	/* attendre la reponse finale des participants */
	for (int i=0; i<3; i++) {
	  m = attendre_message().contenu();
	  System.out.println("Coord a reçu " + m);
	}
	
	/* repondre à l'application */
	String reponse = (decision_valider ? M.OK : M.ERREUR);
	envoyer_message("AppliCliente", reponse);
      }
    }
    catch(Exception e) {
      exception(e);
    }
  }
}


/**
 *   PARTICIPANT
 *   ===========
 */
class Participant extends Entite {
  private Sim_uniform_obj duree, abort ;
  private boolean panne;

  Participant(String name, int x, int y, String image, boolean panne) {
    super(name, image, x, y);
    this.panne = panne;

    /* la duree d'un traitement est comprise dans [90,110] */
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

	/* le participant se prepare a voter, cela dure un certain temps (aléatoire) */
	sim_process(duree.sample());
	String vote = ( abort.sample() > TAUX_ABORT ? M.VOTE_COMMIT : M.VOTE_ABORT );

	/* envoyer le vote */
	envoyer_message("Coord", vote);
	
	if(panne){
		panne(500);
		System.out.println("PANNE\n");
	}else{
	
		/* Etape 2 : le participant attend la décision du coordinateur */
		m = attendre_message().contenu();

		/* le participant met un certain temps pour finaliser l'opération décidée de comit ou d'abort */
		sim_process(duree.sample());

		/* il averti le coordinateur qu'il vient de finir */
		envoyer_message("Coord", M.OK);
	}

	
      }
    }
    catch(Exception e) {
      exception(e);
    }
  }
}


/**
   Une entite generique
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
      throw new ExceptionMessageFinSimul("[A] message null signalant la fin de la simulation");
    }
    else {
      sim_completed(e);
      return m;
    }
  }

  /**
   Attendre un message avec timeout
   */
  protected Message attendre_message_timeout(int timeout) throws Exception {      
    Sim_event e = new Sim_event();
    double restant = sim_wait_for(timeout, e);  
    Message m = (Message) e.get_data();
    if(restant == 0) {
      return new Message("", M.TIMEOUT);
    }	
    else if (m == null) {
      throw new ExceptionMessageFinSimul("[B] message null signalant la fin de la simulation");
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
      System.out.println("[C]: reception d'un message innatendu '" + m + "'. Le message aurait du etre " + prevu);
      throw new RuntimeException("Arret immediat");
    }
  }

  /* se mettre en panne pendant le temps t */
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

  /* gestion des exceptions */
  protected void exception(Exception e) {
    if( e instanceof ExceptionMessageFinSimul) {
      System.out.println("Entite " + get_name() + ": " + e.getMessage());
    }
    else {
      System.out.println("# exception dans l'entite " + get_name() + " ." + e.getMessage());
      e.printStackTrace();
      throw new RuntimeException("Arret immediat");
    }
  }
} // fin de la classe Entité



/*
  Les messages transmis entre l'application, le coordinateur et les participants
*/
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
  Exception lors de la réception d'un message de fin de simulation
*/
class ExceptionMessageFinSimul extends Exception {
  ExceptionMessageFinSimul(String m) {super(m); }
}



/*
  Le simulateur
*/
public class Exemple2b extends Anim_applet {

  public void anim_layout() {
    
    /* creer les entites */


    /* creer l'appli cliente */
    AppliCliente app = new AppliCliente("AppliCliente", 10, 60, "client");
    app.add_port(new Sim_port("Coord", "port", Anim_port.RIGHT, 40));

    /* creer le coordinateur */
    Coordinateur coord = new Coordinateur("Coord", 140, 60, "coord");
    coord.add_port(new Sim_port("AppliCliente", "port", Anim_port.LEFT, 40));
    coord.add_port(new Sim_port("Participant1", "port", Anim_port.RIGHT, 20));
    coord.add_port(new Sim_port("Participant2", "port", Anim_port.RIGHT, 40));
    coord.add_port(new Sim_port("Participant3", "port", Anim_port.RIGHT, 60));

    /* creer le participant 1 */
    Participant p1 = new Participant("Participant1", 370, 10, "base1", false);
    p1.add_port(new Sim_port("Coord", "port", Anim_port.LEFT, 40));

    /* creer le participant 2 */
    Participant p2 = new Participant("Participant2", 370, 110, "base2", false);
    p2.add_port(new Sim_port("Coord", "port", Anim_port.LEFT, 40));

 	/* creer le participant 2 */
    Participant p3 = new Participant("Participant3", 370, 210, "base3", true);
    p3.add_port(new Sim_port("Coord", "port", Anim_port.LEFT, 40));

    /* relier les entites */
    Sim_system.link_ports("AppliCliente", "Coord", "Coord", "AppliCliente");
    Sim_system.link_ports("Coord", "Participant1", "Participant1", "Coord");
    Sim_system.link_ports("Coord", "Participant2", "Participant2", "Coord");
    Sim_system.link_ports("Coord", "Participant3", "Participant3", "Coord");
  }

  public void sim_setup() {
    /* terminer la simulation après N transactions */
    int nb_transactions = 4;
    Sim_system.set_termination_condition(Sim_system.EVENTS_COMPLETED, "AppliCliente", 1, nb_transactions, false);
  }

}
