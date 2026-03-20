
package n7.facade;

import java.util.Collection;
import java.util.HashMap;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
public class Facade {

    // String db_url = "jdbc:hsqldb:hsql://localhost/xdb";
    // String db_user = "sa";
    // Connection con;

    HashMap<Integer, Personne> personnes = new HashMap<Integer, Personne>();
    HashMap<Integer, Adresse> adresses = new HashMap<Integer, Adresse>();

    // @Autowired
    // public Facade()  {
    //     try {
    //         Class.forName("org.hsqldb.jdbc.JDBCDriver");
    //         con = DriverManager.getConnection(db_url, db_user, null);
    //     } catch (Exception e) {
    //         e.printStackTrace();;
    //     }
        
        
    // }
 
    @GetMapping("/ajoutPersonne")
    public void ajoutPersonne(String nom, String prenom) {
        // String sql = "INSERT INTO Personne (nom, prenom) VALUES ('" + nom + "', '" + prenom + "')";
        // try{
        //     Statement stmt = con.createStatement();
        //     stmt.executeUpdate(sql);
        //     stmt.close();
        // } catch(SQLException e){
        //     e.printStackTrace();
        // }

        int id = personnes.size() + 1;
        Personne p = new Personne(prenom, nom, id);
        personnes.put(id, p);
    }

    @GetMapping("/ajoutAdresse")
    public void ajoutAdresse(String rue, String ville) {
        // String sql = "INSERT INTO Adresse (rue, ville) VALUES ('" + rue + "', '" + ville + "')";
        // try{
        //     Statement stmt = con.createStatement();
        //     stmt.executeUpdate(sql);
        //     stmt.close();
        // } catch(SQLException e){
        //     e.printStackTrace();
        // }

        int id = adresses.size() + 1;
        Adresse a = new Adresse(rue, ville, id);
        adresses.put(id, a);
    }

    @GetMapping("/listePersonne")
    public Collection<Personne> listePersonne() {
        // String sql = "SELECT * FROM Personne";
        // try{
        //     Statement stmt = con.createStatement();
        //     ResultSet rs = stmt.executeQuery(sql);
        //     HashMap<Integer,Personne> personnes = new HashMap<Integer,Personne>();
        //     while(rs.next()){
        //         personnes.put(rs.getInt("id"), new Personne(rs.getString("prenom"), rs.getString("nom"), rs.getInt("id")));
        //     }
        //     stmt.close();
        //     Collection<Personne> liste = personnes.values();
        //     return liste;
        // } catch(SQLException e){
        //     e.printStackTrace();
        // }
        // Collection<Personne> list = new ArrayList<Personne>();
        return personnes.values();
    }

    @GetMapping("/listeAdresse")
    public Collection<Adresse> listeAdresse() {
        // String sql = "SELECT * FROM Adresse";
        // try{
        //     Statement stmt = con.createStatement();
        //     ResultSet rs = stmt.executeQuery(sql);
        //     HashMap<Integer,Adresse> adresses = new HashMap<Integer,Adresse>();
        //     while(rs.next()){
        //         adresses.put(rs.getInt("id"), new Adresse(rs.getString("rue"), rs.getString("ville"), rs.getInt("id"), rs.getInt("personneid")));
        //     }
        //     stmt.close();
        //     Collection<Adresse> liste = adresses.values();
        //     return liste;
        // } catch(SQLException e){
        //     e.printStackTrace();
        //     return null;
        // }

        return adresses.values();
    }

    @GetMapping("/associer")
    public void associer(int personneId, int adresseId) {
        // String sql = "UPDATE Adresse SET personneid = " + personneId + " WHERE id = " + adresseId;
        // try{
        //     Statement stmt = con.createStatement();
        //     stmt.executeUpdate(sql);
        //     stmt.close();
        // } catch(SQLException e){
        //     e.printStackTrace();
        // }

        Adresse a = adresses.get(adresseId);
        a.setPersonneId(personneId);
        adresses.put(adresseId, a);
    }

}
