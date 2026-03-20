package pack;

import java.io.IOException;

import javax.swing.text.html.HTML;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Serv")
public class Serv extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String s1 = request.getParameter("nb1");
        String s2 = request.getParameter("nb2");
        int nb1 = Integer.parseInt(s1);
        int nb2 = Integer.parseInt(s2);
        int sum = nb1 + nb2;
        request.setAttribute("resultat", sum);
        request.getRequestDispatcher("Calc.jsp").forward(request, response);
        //response.getWriter().println("<html><body>La somme de " + nb1 + " et " + nb2 + " est " + sum + "</body></html>");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}