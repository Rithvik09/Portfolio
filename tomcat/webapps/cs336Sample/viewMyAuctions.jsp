<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Auctions</title>
</head>
<body>
<%@ page import="java.sql.*" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='success.jsp'> [Return to Home Page]</a> <br> <br>

<% 

String seller = "" + session.getAttribute("user");

try {
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    Statement st = con.createStatement();
    
    String sql = "SELECT auction_id, auction_status, seller, start_price, bid_increment, hidden_min_price, closing_date, item_title, " + 
    		"item_description, category, brand, clothing_condition, color, size FROM auction WHERE seller = ?;";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, seller);
    ResultSet rs = ps.executeQuery();
    
    boolean hasAuctions = false;

%>

<table>
	<tr>
		<th>Auction Id</th>
		<th>Status</th>
		<th>Item Title</th>
		<th>Description</th>
		<th>Start Price</th>
		<th>Bid Increment</th>
		<th>Hidden Min Price</th>
		<th>Closing Date</th>
		<th>Category</th>
		<th>Brand</th>
		<th>Condition</th>
		<th>Color</th>
		<th>Size</th>
	</tr>

<% 

while (rs.next()) {
	hasAuctions = true;

%>

<tr>
	<td><%=rs.getInt("auction_id")%> </td>
	<td><%=rs.getString("auction_status")%></td>
	<td><%=rs.getString("item_title")%></td>
	<td><%=rs.getString("item_description")%></td>
	<td><%=rs.getInt("start_price")%></td>
	<td><%=rs.getInt("bid_increment")%></td>
	<td><%=rs.getInt("hidden_min_price")%></td>
	<td><%=rs.getTimestamp("closing_date")%></td>
	<td><%=rs.getString("category")%></td>
	<td><%=rs.getString("brand")%></td>
	<td><%=rs.getString("clothing_condition")%></td>
	<td><%=rs.getString("color")%></td>
	<td><%=rs.getString("size")%></td>
</tr>

<%

}

if (hasAuctions == false) {

%>

<tr>
	<td> You have no auctions.</td>
</tr>

<%
}

} catch (Exception e) {
	out.println(e);
}
%>

</table>

</body>
</html>