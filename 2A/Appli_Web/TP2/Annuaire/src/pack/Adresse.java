package pack;

public class Adresse {
    private String rue;
    private String ville;
    private Integer id;
    private Integer personneId;

    public Adresse(String rue, String ville, Integer id) {
        this.rue = rue;
        this.ville = ville;
        this.id = id;
    }

    public Adresse(String rue, String ville, Integer id, Integer personneId) {
        this.rue = rue;
        this.ville = ville;
        this.id = id;
        this.personneId = personneId;
    }

    public Integer getPersonneId() {
        return personneId;
    }
    public void setPersonneId(Integer personneId) {
        this.personneId = personneId;
    }
    
    public String getRue() {
        return rue;
    }
    public void setRue(String rue) {
        this.rue = rue;
    }
    public String getVille() {
        return ville;
    }
    public void setVille(String ville) {
        this.ville = ville;
    }
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }
}
