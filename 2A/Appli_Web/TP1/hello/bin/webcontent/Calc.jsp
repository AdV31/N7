<html>
    <head><title>Serv</title></head>
    <body>
        <h1>Serv</h1>
        <form action="/hello/Serv" method="get">
            nb1 <input type="text" name="nb1"><br/>
            nb2 <input type="text" name="nb2"><br/>
            <button type="submit">Sommer</button>
            resultat :  <%=request.getAttribute("resultat")%>
        </form>
    </body>
</html>