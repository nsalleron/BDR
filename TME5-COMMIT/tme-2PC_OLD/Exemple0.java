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
    add_port(new Sim_port("Port", "port", Anim_port.RIGHT, 40));
  }

  public void body() {
    try {
      
      while (Sim_system.running()) {
	
	/* lancer la validation */
	envoyer_message("Port", M.COMMIT);
	
	/* attendre la fin de la validation */
	String reponse = attendre_message();
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
    add_port(new Sim_port("A", "port", Anim_port.LEFT, 40));
    add_port(new Sim_port("B1", "port", Anim_port.RIGHT, 20));
    add_port(new Sim_port("B2", "port", Anim_port.RIGHT, 60));
  }

  public void body() {

    String m = null;
    
    try {      
      while (Sim_system.running()) {
	m = attendre_message();

	/* phase 1 : demander aux participants de se preparer*/
	envoyer_message("B1", M.PREPARE);
	envoyer_message("B2", M.PREPARE);
		
	/* attendre le vote des participants */
	boolean decision_valider = true;
	for (int i = 0; i < 2; i++) {
	  m = attendre_message();
	  System.out.println("Coord a reçu " + m);
	  
	  if(m == M.VOTE_ABORT) {	  
	    decision_valider = false;
	  }
	}
	
	/* phase 2 */
	String decision = (decision_valider ? M.COMMIT : M.ABORT);
	envoyer_message("B1", decision);
	envoyer_message("B2", decision);
		
	/* attendre la reponse finale des participants */
	for (int i=0; i<2; i++) {
	  m = attendre_message();
	  System.out.println("Coord a reçu " + m);
	}
	
	/* repondre à l'application */
	String reponse = (decision_valider ? M.OK : M.ERREUR);
	envoyer_message("A", reponse);
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
  private Sim_normal_obj duree;
  private Sim_uniform_obj abort;

  Participant(String name, int x, int y, String image) {
    super(name, image, x, y);
    add_port(new Sim_port("Port", "port", Anim_port.LEFT, 40));

    duree = new Sim_normal_obj("Duree", 100, 50);
    add_generator(duree);

    abort = new Sim_uniform_obj("Abort", 1, 100);
    add_generator(abort);
  }

  public void body() {

    /* le pourcentage d'abandon */
    int TAUX_ABORT = 30;

    try {
      while (Sim_system.running()) {

	String m = attendre_message();
	sim_process(duree.sample());

	String reponse = "";
	if( m == M.PREPARE) {
	  /* reponse pendant l'etape 1*/
	  reponse = ( abort.sample() > TAUX_ABORT ? M.VOTE_COMMIT : M.VOTE_ABORT );
	}
	else {
	  /* reponse pendant l'etape 2 */
	  reponse = M.OK;
	}
	envoyer_message("Port", reponse);
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
  }

  protected String attendre_message() throws Exception {      
    Sim_event e = new Sim_event();
    sim_get_next(e);  
    String r = (String) e.get_data();
    if (r == null) {
      throw new Exception("fin");
    }
    else {
      sim_completed(e);
      return r;
    }
  }

  protected String attendre_message_timeout(int timeout) throws Exception {      
    Sim_event e = new Sim_event();
    double restant = sim_wait_for(timeout, e);  
    String r = (String) e.get_data();
    if(restant == 0) {
      return M.TIMEOUT;
    }	
    else if (r == null) {
      throw new Exception("fin");
    }
    else {
      sim_completed(e);
      return r;
    }
  }


  protected void envoyer_message(String port, String message) {
    sim_schedule(port, 0, 1, message);    
    sim_trace(1, "S " + port + " " + message);
  }
}
  

/*
  Le simulateur
*/
public class Exemple0 extends Anim_applet {

  public void anim_layout() {
    
    /* creer les entites */
    AppliCliente app = new AppliCliente("AppliCliente", 10, 60, "client");
    Coordinateur coord = new Coordinateur("Coord", 140, 60, "coord");
    Participant p1 = new Participant("Participant1", 370, 10, "base1");
    Participant p2 = new Participant("Participant2", 370, 110, "base2");

    /* relier les entites */
    Sim_system.link_ports("AppliCliente", "Port", "Coord", "A");
    Sim_system.link_ports("Coord", "B1", "Participant1", "Port");
    Sim_system.link_ports("Coord", "B2", "Participant2", "Port");
  }

  public void sim_setup() {
    /* terminer la simulation après N transactions */
    int nb_transactions = 4;
    Sim_system.set_termination_condition(Sim_system.EVENTS_COMPLETED, "AppliCliente", 1, nb_transactions, false);
  }

}
