<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete Account</title>
</head>
<body>

<%@ page import="java.sql.*" %>

<%

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

String user = request.getParameter("user");

try {
	
	PreparedStatement ps = con.prepareStatement("DELETE FROM users WHERE username = ?");
	ps.setString(1, user);
	ps.executeUpdate();

%>

<p>Account successfully deleted.</p>
<p>Redirecting to Manage User's Account Page.</p>


<%

response.setHeader("Refresh", "3; URL=manageAccounts.jsp");

} catch (Exception e) {
	out.println(e);
}


%>



</body>
</html>