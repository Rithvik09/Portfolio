<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete Item Alert</title>
</head>
<body>

<%@ page import="java.sql.*" %>

<%

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

try {
	
	String user = "" + session.getAttribute("user");
	String category = request.getParameter("category");
	String brand = request.getParameter("brand");
	String color = request.getParameter("color");
	String size = request.getParameter("size");

	
	PreparedStatement ps = con.prepareStatement("DELETE FROM alert_for_item WHERE username = ? AND category = ? AND brand = ? AND color = ? AND size = ?;");
	ps.setString(1, user);
	ps.setString(2, category);
	ps.setString(3, brand);
	ps.setString(4, color);
	ps.setString(5, size);

	ps.executeUpdate();

%>

<p>Alert successfully removed.</p>
<p>Redirecting back.</p>


<%

response.setHeader("Refresh", "1; URL=setItemAlerts.jsp");

} catch (Exception e) {
	out.println(e);
}


%>



</body>
</html>