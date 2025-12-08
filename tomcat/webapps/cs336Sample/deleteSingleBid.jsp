<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Deleting Bid</title>
</head>
<body>

<%@ page import="java.sql.*" %>

<%

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

String bidId = request.getParameter("bid_id");

try {
	
	PreparedStatement ps = con.prepareStatement("DELETE FROM bids WHERE bid_id = ?");
	ps.setString(1, bidId);
	ps.executeUpdate();

%>

<p>Bid successfully deleted.</p>
<p>Redirecting back.</p>


<%

response.setHeader("Refresh", "3; URL=manageAuctionsCustomerRep.jsp");

} catch (Exception e) {
	out.println(e);
}


%>



</body>
</html>