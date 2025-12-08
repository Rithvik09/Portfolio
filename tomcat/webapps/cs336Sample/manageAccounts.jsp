<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage User's Accounts</title>
</head>
<body>
<%@ page import="java.sql.*" %>
<a href='customerRepPage.jsp'> [Return to Customer Rep Home Page]</a>

<h1>Manage User's Accounts</h1>

<% 

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

ResultSet rs = st.executeQuery("SELECT username, pass FROM users WHERE is_customer_rep = false");

%>

<table>

<%

while (rs.next()) {
	
	String user = rs.getString("username");
	String pass = rs.getString("pass");


%>

<tr>
	<td><%= user %></td>
	<td><%= pass %></td>
	<td> <a href="manageSingleUser.jsp?user=<%= user %>">[Update Password]</a>
	<td> <a href="deleteAccount.jsp?user=<%= user %>">[Delete Account]</a>

<tr>

<%

}

%>

</table>



</body>
</html>