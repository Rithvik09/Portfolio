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

<a href='success.jsp'>[Return to Home Page]</a>

	<p style="font-size: 30px;">FAQs</p>
	
	<form action="askFaqs.jsp" method="POST">

        <label for="ask">Ask a question:</label>
        <input type="text" name="ask" id="ask" required style="width: 340px;">

        <input type="submit" value="Ask" style="width: 53px;">       
         
    </form>
    
    	<form action="searchFaqs.jsp" method="POST">

        <label for="search">Search for a question:</label>
        <input type="text" name="search" id="search" required style="width: 300px;">

        <input type="submit" value="Search">       
         
    </form>
    
    <br>
    <br>
    
    <%

    Class.forName("com.mysql.jdbc.Driver");
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
	Statement st = con.createStatement();

    try {
    	
        String str = "SELECT * FROM faqs;";
        PreparedStatement ps = con.prepareStatement(str);
		ResultSet result = ps.executeQuery();
       
	%>
	
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
			
	</table>
	
	<%
	
    } catch (Exception e) {
        out.print(e);
    }
    
    %>
    

</body>
</html>