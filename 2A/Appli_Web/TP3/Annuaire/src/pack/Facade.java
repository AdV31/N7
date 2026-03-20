package pack;

import java.util.Collection;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;

@Path("/")
public interface Facade {

    @GET
    @Path("/ajoutPersonne")
    @Consumes("application/json")
    void ajoutPersonne(@QueryParam("nom") String nom, @QueryParam("prenom") String prenom);

    @GET
    @Path("/ajoutAdresse")
    @Consumes("application/json")
    void ajoutAdresse(@QueryParam("rue") String rue, @QueryParam("ville") String ville);

    @GET
    @Path("/listePersonne")
    @Produces("application/json")
    Collection<Personne> listePersonne();

    @GET
    @Path("/listeAdresse")
    @Produces("application/json")
    Collection<Adresse> listeAdresse();

    @POST
    @Path("/associer")
    @Consumes("application/json")
    void associer(@QueryParam("personneId") int personneId, @QueryParam("adresseId") int adresseId);
}