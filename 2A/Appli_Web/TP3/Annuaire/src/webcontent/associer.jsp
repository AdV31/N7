<%@  page language="java" import="pack.*, java.util.*" contentType="text/html;charset=UTF-8" %>
<html>
    <head> <title>Associer une adresse à une personne</title> </head>
    <body>
        <form action="Controller" method="get">
            <ul>
                <% Collection<Personne> personnes = (Collection<Personne>) request.getAttribute("personnes");
                for (Personne p : personnes) {
                    String nomComplet = p.getPrenom() + " " + p.getNom();
                    int personneid = p.getId();%>
                <li>
                    <label for="personneId"><%= nomComplet %> : </label>
                    <input type="radio" id="personne" name="personneId" value="<%= personneid %>">
                </li>
                    <url>
                        <% Collection<Adresse> adresses = (Collection<Adresse>) request.getAttribute("adresses");
                            for (Adresse a : adresses) {
                                String adresseComplete = a.getRue() + ", " + a.getVille();
                                int adresseid = a.getId(); %>
                        <li><blockquote>
                            <label for="adresseId"><%= adresseComplete %> : </label>
                            <input type="radio" id="adresse" name="adresseId" value="<%= adresseid %>">
                        </blockquote></li>
                        <% } %>
                    </url>
                </li>
                <% } %>
            </ul>
            <input type="hidden" name="op" value="associer" >
            <button type="submit">Associer</button>
        </form>
    </body>
</html>
