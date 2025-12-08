<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reply to FAQs</title>
</head>
<body>
<%@ page import="java.sql.*" %>
<a href='customerRepPage.jsp'> [Return to Customer Rep Home Page]</a>

	<%
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    Statement st = con.createStatement();

    try {
        
        
        String str = "SELECT * FROM faqs WHERE answer = '*Question not answered yet*';";
        PreparedStatement ps = con.prepareStatement(str);
        ResultSet result = ps.executeQuery();
        
    %>
    
        <table>
    
        <tr>    
            <td><u>Question</u></td>
            <td><u>Submit Answer</u></td> 
        </tr>
        
    <%
        
    while (result.next()) {
            
        String question = result.getString("question");
        String answer = result.getString("answer");

    %>
                
            <tr>
                <td><%= question %></td>
                <td>            
                    <form action="replyAdded.jsp" method="POST">
                        
                        <input type="hidden" name="question" value="<%= question %>">
                        <input type="text" name="reply" id="reply" required style="width: 300px;">
                
                        <input type="submit" value="Reply">       
             
                    </form> 
                </td>
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