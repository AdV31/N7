package pack;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collection;
import java.util.HashMap;



public class Facade {

    String db_url = "jdbc:hsqldb:hsql://localhost/xdb";
    String db_user = "sa";
    Connection con;

    public Facade() throws ClassNotFoundException, SQLException {
        try {
            Class.forName("org.hsqldb.jdbc.JDBCDriver");
        } catch (ClassNotFoundException e) {
            Class.forName("org.hsqldb.jdbcDriver");
        }
        con = DriverManager.getConnection(db_url, db_user, null);
    }
 
    public void ajoutPersonne(String nom, String prenom) {
        String sql = "INSERT INTO Personne (nom, prenom) VALUES ('" + nom + "', '" + prenom + "')";
        try{
            Statement stmt = con.createStatement();
            stmt.executeUpdate(sql);
            stmt.close();
        } catch(SQLException e){
            e.printStackTrace();
        }
    }

    public void ajoutAdresse(String rue, String ville) {
        String sql = "INSERT INTO Adresse (rue, ville) VALUES ('" + rue + "', '" + ville + "')";
        try{
            Statement stmt = con.createStatement();
            stmt.executeUpdate(sql);
            stmt.close();
        } catch(SQLException e){
            e.printStackTrace();
        }
    }

    public Collection<Personne> listePersonne() {
        String sql = "SELECT * FROM Personne";
        try{
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            HashMap<Integer,Personne> personnes = new HashMap<Integer,Personne>();
            while(rs.next()){
                personnes.put(rs.getInt("id"), new Personne(rs.getString("prenom"), rs.getString("nom"), rs.getInt("id")));
            }
            stmt.close();
            Collection<Personne> liste = personnes.values();
            return liste;
        } catch(SQLException e){
            e.printStackTrace();
            return null;
        }
    }

    public Collection<Adresse> listeAdresseAssocier() {
        String sql = "SELECT * FROM Adresse";
        try{
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            HashMap<Integer,Adresse> adresses = new HashMap<Integer,Adresse>();
            while(rs.next()){
                adresses.put(rs.getInt("id"), new Adresse(rs.getString("rue"), rs.getString("ville"), rs.getInt("id")));
            }
            stmt.close();
            Collection<Adresse> liste = adresses.values();
            return liste;
        } catch(SQLException e){
            e.printStackTrace();
            return null;
        }
    }

    public Collection<Adresse> listeAdresse() {
        String sql = "SELECT * FROM Adresse";
        try{
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            HashMap<Integer,Adresse> adresses = new HashMap<Integer,Adresse>();
            while(rs.next()){
                adresses.put(rs.getInt("id"), new Adresse(rs.getString("rue"), rs.getString("ville"), rs.getInt("id"), rs.getInt("personneid")));
            }
            stmt.close();
            Collection<Adresse> liste = adresses.values();
            return liste;
        } catch(SQLException e){
            e.printStackTrace();
            return null;
        }
    }

    public void associer(int personneId, int adresseId) {
        String sql = "UPDATE Adresse SET personneid = " + personneId + " WHERE id = " + adresseId;
        try{
            Statement stmt = con.createStatement();
            stmt.executeUpdate(sql);
            stmt.close();
        } catch(SQLException e){
            e.printStackTrace();
        }
    }

}
