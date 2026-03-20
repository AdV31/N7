package vue;

import jakarta.ejb.Singleton;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import modele.Personne;
import modele.Adresse;

/**
 * Facade
 */
@Singleton
public class Facade {

  @PersistenceContext
  private EntityManager em;

  public void ajoutPersonne(String nom, String prenom) {
    Personne personne = new Personne(prenom, nom);
    em.persist(personne);
  }

  public void ajoutAdresse(String rue, String ville) {
    Adresse adresse = new Adresse(ville, rue);
    em.persist(adresse);
  }

  public Collection<Personne> listePersonnes() {
    return em.createQuery("SELECT p FROM Personne p",
        Personne.class).getResultList();
  }

  public Collection<Adresse> listeAdresses() {
    return em.createQuery("SELECT a FROM Adresse a",
        Adresse.class).getResultList();
  }

  public void associer(int personneId, int adresseId) {
    Personne personne = em.find(Personne.class, personneId);
    Adresse adresse = em.find(Adresse.class, adresseId);
    if (!(adresse == null) && !(personne == null)) {
      adresse.setOwner(personne);
    } else {
      throw new RuntimeException("adresse (" + adresse + ") ou personne (" + personne + ") est null");
    }
  }

  public HashMap<Personne, Set<Adresse>> lister() {
    HashMap<Personne, Set<Adresse>> assoc = new HashMap<>();
    for (Personne p : listePersonnes()) {
      assoc.put(p, new HashSet<>(p.getAdresses()));
    }
    return assoc;
  }
}
