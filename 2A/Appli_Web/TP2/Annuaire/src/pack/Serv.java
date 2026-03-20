package pack;

import java.io.IOException;

import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Serv")
public class Serv extends HttpServlet {
    Facade facade;

    public Serv() throws ClassNotFoundException, SQLException {
        super();
        facade = new Facade();
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
                    request.setAttribute("adresses", facade.listeAdresseAssocier());
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