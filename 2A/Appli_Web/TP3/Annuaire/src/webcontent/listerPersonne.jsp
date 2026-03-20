<%@  page language="java" import="pack.*, java.util.*" contentType="text/html;charset=UTF-8" %>
<html>
    <head> <title>Liste des personnes</title> </head>
    <body>
        <h1>Liste des personnes</h1>
        <ul>
            <% Collection<Personne> personnes = (Collection<Personne>) request.getAttribute("personnes");
               for (Personne p : personnes) {
                  String nomComplet = p.getPrenom() + " " + p.getNom(); %>
            <li><%= nomComplet %>
                <url>
                    <% Collection<Adresse> adresses = (Collection<Adresse>) request.getAttribute("adresses");
                        String adresseComplete = "";
                        for (Adresse a : adresses) {
                            if (a.getPersonneId() == p.getId()) {
                                adresseComplete = a.getRue() + ", " + a.getVille();%>
                                <li><blockquote><%= adresseComplete %></blockquote></li>
                            <% }%>
                    <% } %>
                </url>
            </li>
            <% } %>
        </ul>
    </body>
</html>