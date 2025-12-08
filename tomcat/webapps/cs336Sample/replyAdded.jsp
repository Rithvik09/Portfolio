<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reply Added</title>
</head>
<body>
<%@ page import="java.sql.*" %>

<%

	Class.forName("com.mysql.jdbc.Driver");
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
	Statement st = con.createStatement();
	
	try {
		
		String reply = request.getParameter("reply");
		String question = request.getParameter("question");
		
		String str = "UPDATE faqs SET answer = ? WHERE question = ?";
		PreparedStatement ps = con.prepareStatement(str);
		ps.setString(1, reply);
		ps.setString(2, question);
		ps.execute();		
    
%>

<p>Reply submitted successfully.<p>
<p>Your reply has been submitted. Redirecting to the Reply to FAQs section.<p>

<%

	response.setHeader("Refresh", "3; URL=reply.jsp");

	} 
	
	catch (Exception e) {
		out.println(e);
	}

%>



</body>
</html>