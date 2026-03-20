package pack;

import java.io.IOException;

import javax.ws.rs.core.UriBuilder;

import org.jboss.resteasy.client.jaxrs.ResteasyClient;
import org.jboss.resteasy.client.jaxrs.ResteasyClientBuilder;
import org.jboss.resteasy.client.jaxrs.ResteasyWebTarget;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Controller")
public class Controller extends HttpServlet {

    final String path ="http://localhost:8080/facade";
    Facade facade;

    public Controller() {
        ResteasyClient client = new ResteasyClientBuilder().build();
        ResteasyWebTarget target = client.target(UriBuilder.fromPath(path));
        facade = target.proxy(Facade.class);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            switch(request.getParameter("op")){
                case "ajouterPersonne":
                    String nom = request.getParameter("nom");
                    String prenom = request.getParameter("prenom");
                    facade.ajoutPersonne(nom, prenom);
                    request.getRequestDispatcher("index.html").forward(request, response);
                break;
                case "ajouterAdresse":
                    String rue = request.getParameter("rue");
                    String ville = request.getParameter("ville");
                    facade.ajoutAdresse(rue, ville);
                    request.getRequestDispatcher("index.html").forward(request, response);
                break;
                case "associer":
                    int personneId = Integer.parseInt(request.getParameter("personneId"));
                    int adresseId = Integer.parseInt(request.getParameter("adresseId"));
                    facade.associer(personneId, adresseId);
                    request.getRequestDispatcher("index.html").forward(request, response);
                break;
                case "associerForm":
                    request.setAttribute("personnes", facade.listePersonne());
                    request.setAttribute("adresses", facade.listeAdresse());
                    request.getRequestDispatcher("associer.jsp").forward(request, response);
                break;
                case "listerPersonne":
                    request.setAttribute("personnes", facade.listePersonne());
                    request.setAttribute("adresses", facade.listeAdresse());
                    request.getRequestDispatcher("listerPersonne.jsp").forward(request, response);
                break;
            }
    }
}