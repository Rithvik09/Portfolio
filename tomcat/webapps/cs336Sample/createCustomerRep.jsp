<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@ page import="java.sql.*" %>


<h2>Create Customer Rep Account</h2>

<%
	String user = request.getParameter("username");
	String pass = request.getParameter("password");
    
	if (user != null && pass != null){
		try{
			Class.forName("com.mysql.jdbc.Driver");
		    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
		    Statement st = con.createStatement();
		    
		    st.executeUpdate("INSERT INTO users (username, pass, is_customer_rep) VALUES ('" + user + "', '" + pass + "', true)");
		    out.println("Customer Rep Created Successfully!");
		   
		}catch (Exception e){
			out.println("Error");
		}
	}else{

%>

<form action="createCustomerRep.jsp" method="POST">
    Username: <input type="text" name="username" required><br>
    Password: <input type="password" name="password" required><br>
    <button type="submit">Create Account</button>
</form>

<%
} 
%>


<br><br>
<a href="adminPage.jsp"><button>Back to Admin Page</button></a>


</body>
</html>