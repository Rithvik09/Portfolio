<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Search for a Question</title>
</head>
<body>
<%@ page import="java.sql.*" %>

<a href='faqs.jsp'>[Return to FAQs]</a>

	
    <%

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    Statement st = con.createStatement();

    try {
            
        
        String search = request.getParameter("search");

        String str = "SELECT * FROM faqs WHERE question LIKE ?;";
        
        PreparedStatement ps = con.prepareStatement(str);
        ps.setString(1, "%" + search + "%");
        ResultSet result = ps.executeQuery();
        
	%>
	
	<p style="font-size: 30px;">Search Results:</p>
	
	
		<table>
	
		<tr>    
			<td><u>Question</u></td>
			<td><u>Answer</u></td>
			
			
		</tr>
		
	<%
		
	while (result.next()) {
			
		String question = result.getString("question");
		String answer = result.getString("answer");
				
			
	%>
			    
			<tr>
		        <td><%= question %></td>
		        <td><%= answer %></td>

			</tr>
				
	<% 
			
	}

	%>
	
	<%
	
    } catch (Exception e) {
        out.print(e);
    }
    
    %>
    

</body>
</html>