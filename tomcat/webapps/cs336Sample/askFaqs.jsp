<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Ask a Question</title>
</head>
<body>
<%@ page import="java.sql.*" %>


<%

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

    try {
    	
        
        String question = request.getParameter("ask");

        String str = "INSERT INTO faqs VALUES (?, '*Question not answered yet*')";
        
        PreparedStatement ps = con.prepareStatement(str);
        ps.setString(1, question);
        ps.executeUpdate();
        
	%>
	
	<p>Question Submitted Successfully. Redirecting to the FAQ page.</p>

   <%
      response.setHeader("Refresh", "3; URL=faqs.jsp");
   %>

	
	<%
	
    } catch (Exception e) {
        out.print(e);
    }
    
    %>
    
    
</body>
</html>