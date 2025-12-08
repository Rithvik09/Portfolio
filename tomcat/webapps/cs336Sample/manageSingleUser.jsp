<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Password</title>
</head>
<body>
<%@ page import="java.sql.*" %>
<a href = "manageAccounts.jsp"> [Back to Manage Accounts]</a>

<h1>Update User Password</h1>

<%
String user = request.getParameter("user");
String newPassword = request.getParameter("newPassword");
if(newPassword == null){
%>

<form action="manageSingleUser.jsp" method="POST">
<input type="hidden" name="user" value="<%=user%>">
New Password: <input type="text" name="newPassword" required>
<br><br>
<button type="submit">Save New Password</button>
<% 
	}else{
		try{
			Class.forName("com.mysql.jdbc.Driver");
			Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
			Statement st = con.createStatement();
			
			PreparedStatement ps = con.prepareStatement("UPDATE users SET pass = ? WHERE username = ?");
			ps.setString(1,newPassword);
			ps.setString(2,user);
			ps.executeUpdate();
			
			%>
			
			<p>Password for user '<%=user %>' has been updated successfully.</p>
			<p> Redirecting to Manage User's Account Page</p>
			
			<% 
		
		response.setHeader("Refresh", "3, URL=manageAccounts.jsp");
		}catch(Exception e){
			out.println(e);
		}
	}
%>

</form>

</body>
</html>