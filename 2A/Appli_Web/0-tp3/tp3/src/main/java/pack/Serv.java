package pack;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Set;

import jakarta.servlet.annotation.WebServlet;
import jakarta.ejb.EJB;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modele.Adresse;
import modele.Personne;
import vue.Facade;

@WebServlet("/Serv")
public class Serv extends HttpServlet {

  @EJB
  Facade facade;

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws ServletException, IOException {

    req.setAttribute("facade", facade);
    String op = req.getParameter("op");
    RequestDispatcher rd = req.getRequestDispatcher("index.html");

    if (op != null) {
      req.setAttribute("listePersonnes", facade.listePersonnes());
      req.setAttribute("listeAdresses", facade.listeAdresses());
      switch (op) {
        case "lister":
          resp.setContentType("text/html;charset=UTF-8");
          HashMap<Personne, Set<Adresse>> assoc = facade.lister();
          try(PrintWriter out = resp.getWriter()) {
            if (assoc.isEmpty()) {
              out.println("Aucune association");
            } else {
              System.out.println(assoc); // DEBUG
              for (Personne personne : assoc.keySet()) {
                out.println(personne.getNom() + " " + personne.getPrenom() + "<br>");
                for (Adresse adresse : assoc.get(personne)) {
                  out.println("&nbsp;&nbsp;&nbsp;&nbsp;" + adresse.getRue() + " " + adresse.getVille() + "<br>");
                }
              }
            }
          }
          return;
          // rd = req.getRequestDispatcher("lister.jsp");
          // break;
        case "associer":
          rd = req.getRequestDispatcher("associer.jsp");
          break;
      }
    }
    rd.forward(req, resp);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws ServletException, IOException {

    switch (req.getParameter("op")) {
      case "ajoutpersonne":
        facade.ajoutPersonne(req.getParameter("nom"),
            req.getParameter("prenom"));
        break;
      case "ajoutadresse":
        facade.ajoutAdresse(req.getParameter("rue"),
            req.getParameter("ville"));
        break;
      case "associer":
        facade.associer(Integer.parseInt(req.getParameter("personneId")),
            Integer.parseInt(req.getParameter("adresseId")));
        break;
    }

    RequestDispatcher rd = req.getRequestDispatcher("index.html");
    rd.forward(req, resp);
  }
}
