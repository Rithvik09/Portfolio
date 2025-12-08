<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Logout Page</title>
</head>
<body>
    <% 
        session.invalidate();
        //session.getAttribute("user"); // this will throw an error
        response.sendRedirect("login.jsp");
    %>
</body>
</html>
