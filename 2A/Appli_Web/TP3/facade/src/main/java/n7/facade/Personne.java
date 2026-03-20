package n7.facade;

@Entity
public class Personne {

    private String prenom;
    private String nom;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Integer id;
    

    public Personne(String prenom, String nom, Integer id) {
        this.prenom = prenom;
        this.nom = nom;
        this.id = id;
    }

    public String getPrenom() {
        return prenom;
    }

    public String getNom() {
        return nom;
    }

    public Integer getId() {
        return id;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public void setId(Integer id) {
        this.id = id;
    }

}
