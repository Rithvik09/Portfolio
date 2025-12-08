<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert Item Alert</title>
</head>
<body>
<%@ page import="java.sql.*" %>

<%

String category = request.getParameter("category");
String brand = request.getParameter("brand");
String color = request.getParameter("color");
String size = request.getParameter("size");

try {

	
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    Statement st = con.createStatement();
    
	String seller = "" + session.getAttribute("user");

    String str = "SELECT 1 FROM alert_for_item WHERE username = ? AND category = ? AND brand = ? AND color = ? AND size = ?";
	PreparedStatement ps = con.prepareStatement(str);
	ps.setString(1, seller);
	ps.setString(2, category);
	ps.setString(3, brand);
	ps.setString(4, color);
	ps.setString(5, size);
	ResultSet rs = ps.executeQuery();
	
	
	if (rs.next()) {
		
%>

		<p>Alert already exists for item.</p>
		<p>Redirecting you back.</p>

<%

		response.setHeader("Refresh", "3; URL=setItemAlerts.jsp");


	} else {
		String str2 = "INSERT INTO alert_for_item (username, category, brand, color, size) VALUES (?, ?, ?, ?, ?)";
		PreparedStatement ps2 = con.prepareStatement(str2);
		ps2.setString(1, seller);
		ps2.setString(2, category);
		ps2.setString(3, brand);
		ps2.setString(4, color);
		ps2.setString(5, size);
		
		ps2.executeUpdate();

%>

		<p>Alert successfully created for item.</p>
		<p>Redirecting you back.</p>	
		

<% 	

		response.setHeader("Refresh", "1; URL=setItemAlerts.jsp");

	}

   
} catch (Exception e) {
	out.println(e);
}

%>

</body>
</html>