<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Create Account Result</title>
</head>
<body>
<%@ page import="java.sql.*" %>

<%
    String userid = request.getParameter("username");
    String pwd = request.getParameter("password");

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    Statement st = con.createStatement();

    try {
        st.executeUpdate(
            "INSERT INTO users (username, pass, is_customer_rep) VALUES ('" 
            + userid + "', '" + pwd + "', false)"
        );

        out.println("<h2>Account Created Successfully!</h2>");
        out.println("<p>You can now log in.</p>");

    } catch (Exception e) {
        out.println("<h2>Error: Username already exist.</h2>");
    }
%>

<br><br>
<a href="login.jsp"><button>Back to Login</button></a>

</body>
</html>