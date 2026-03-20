<%@ page language="java" import="modele.*, java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Empty JSP File</title>
</head>
<body>
    <form action="Serv" method="post">
        <input type="hidden" name="op" value="associer">
        Choisir la personne :<br>
        <%
          List<Personne> pers = (List<Personne>) request.getAttribute("listePersonnes");
          if (pers.isEmpty()) {
        %>
        <label>Aucune personne inscrite</label><br>
        <%
          } else {
            for (Personne p : pers) {
              int idx = p.getId();
        %>
        <input type="radio" id="personne<%=idx%>" name="personneId" value="<%=idx%>" required>
        <label for="personne<%=idx%>"><%=p.getNom() + " " + p.getPrenom()%></label><br>
        <%
            }
          }
        %>
        <br>

        Choisir l'adresse :<br>
        <%
          List<Adresse> adrs = (List<Adresse>) request.getAttribute("listeAdresses");
          if (adrs.isEmpty()) {
        %>
        <label>Aucune adresse renseignée</label><br>
        <%
          } else {
            for (Adresse a : adrs) {
              int idx = a.getId();
        %>
        <input type="radio" id="adresse<%=idx%>" name="adresseId" value="<%=idx%>" required>
        <label for="adresse<%=idx%>"><%=a.getRue() + " " + a.getVille()%></label><br>
        <%
            }
          }
        %>
        <br>
        <%
          if (!(pers.isEmpty() || adrs.isEmpty())) {
        %>
        <input type="submit" value="OK">
        <%
          }
        %>
    </form>
</body>
</html>
