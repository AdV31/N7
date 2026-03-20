package modele;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;

/**
 * Adresse
 */
@Entity
public class Adresse {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private int id;

  private String ville;

  private String rue;

  @ManyToOne
  private Personne owner; /* can be null */

  public Adresse() {}

  public Adresse (String ville, String rue) {
    this.ville = ville;
    this.rue = rue;
  }

  public int getId() {
    return id;
  }

  public String getVille() {
    return ville;
  }

  public String getRue() {
    return rue;
  }

  public Personne getOwner() {
    return owner;
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setVille(String ville) {
    this.ville = ville;
  }

  public void setRue(String rue) {
    this.rue = rue;
  }

  public void setOwner(Personne owner) {
    this.owner = owner;
  }
}
