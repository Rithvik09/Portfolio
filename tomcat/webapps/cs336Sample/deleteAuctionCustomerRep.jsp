<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete Auction</title>
</head>
<body>

<%@ page import="java.sql.*" %>

<%

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

try {
	
	String auctionId = request.getParameter("auction_id");

	
	PreparedStatement ps = con.prepareStatement("DELETE FROM auction WHERE auction_id = ?;");
	ps.setString(1, auctionId);

	ps.executeUpdate();

%>

<p>Auction successfully removed.</p>
<p>Redirecting back.</p>


<%

response.setHeader("Refresh", "2; URL=manageAuctionsCustomerRep.jsp");

} catch (Exception e) {
	out.println(e);
}


%>



</body>
</html>