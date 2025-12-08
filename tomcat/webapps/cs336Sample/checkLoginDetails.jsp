<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Check Login Page</title>
</head>
<body>
    <%@ page import="java.sql.*" %>
    <%
        String userid = request.getParameter("username");
        String pwd = request.getParameter("password");
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
        Statement st = con.createStatement();
        ResultSet rs;
        
        if ("admin".equals(userid) && "password123".equals(pwd)){
        	session.setAttribute("user", userid);
        	response.sendRedirect("adminPage.jsp");
        	return;
        }
        
        rs = st.executeQuery("select * from users where username='" + userid + "' and pass='" + pwd + "'");
        
        
        
        if (rs.next()) {
            session.setAttribute("user", userid); // the username will be stored in the session
            out.println("welcome " + userid);
            out.println("<a href='logout.jsp'>Log out</a>");
            // check if is_customer rep is true, redirect to customerRepPage.jsp
            boolean isRep = rs.getBoolean("is_customer_rep");
            if(isRep == true){
            	response.sendRedirect("customerRepPage.jsp");
            }else{
            response.sendRedirect("success.jsp");
            }
        } else {
            out.println("Invalid username and/or password <a href='login.jsp'>try again</a>");
        }
    %>
</body>
</html>
