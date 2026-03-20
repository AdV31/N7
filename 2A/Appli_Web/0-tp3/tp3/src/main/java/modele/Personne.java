package modele;

import java.util.List;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

/**
 * Personne
 */
@Entity
public class Personne {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private int id;

  private String prenom;

  private String nom;

  @OneToMany(mappedBy = "owner", fetch = FetchType.EAGER)
  private List<Adresse> adresses;

  public Personne() {}

  public Personne (String prenom, String nom) {
    this.prenom = prenom;
    this.nom = nom;
  }

  public void addAdresse (Adresse adr) {
    adresses.add(adr);
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setNom(String nom) {
    this.nom = nom;
  }

  public void setPrenom(String prenom) {
    this.prenom = prenom;
  }

  public void setAdresses(List<Adresse> adresses) {
    this.adresses = adresses;
  }

  public int getId() {
    return id;
  }

  public String getNom() {
    return nom;
  }

  public String getPrenom() {
    return prenom;
  }

  public List<Adresse> getAdresses() {
    return adresses;
  }
}
