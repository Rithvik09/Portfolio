<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Auctions</title>
<style>
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .closed { background-color: #ffcccc; }
</style>
</head>
<body>
<%@ page import="java.sql.*" %>

<a href='customerRepPage.jsp'>[Return to Home Page]</a> <br> <br>

<% 
String currentUser = "" + session.getAttribute("user");

try {
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    
    String sql = "SELECT a.auction_id, a.auction_status, a.seller, a.start_price, a.bid_increment, " + 
    		"a.closing_date, a.item_title, a.item_description, a.category, a.brand, " + 
    		"a.clothing_condition, a.color, a.size, " +
    		"(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as current_bid, " +
    		"(SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id) as bid_count " +
    		"FROM auction a ORDER BY a.closing_date DESC;";
    
    PreparedStatement ps = con.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
    
    boolean hasAuctions = false;
%>

<h2>Manage Auctions</h2>

<table>
	<tr>
		<th>Auction ID</th>
		<th>Status</th>
		<th>Item</th>
		<th>Description</th>
		<th>Category</th>
		<th>Brand</th>
		<th>Condition</th>
		<th>Color</th>
		<th>Size</th>
		<th>Start Price</th>
		<th>Current Bid</th>
		<th>Bid Increment</th>
		<th>Total Bids</th>
		<th>Closing Date</th>
		<th>Delete Auction/Bid?</th>
	</tr>

<% 
while (rs.next()) {
	hasAuctions = true;
	int auctionId = rs.getInt("auction_id");
	String status = rs.getString("auction_status");
	String seller = rs.getString("seller");
	int startPrice = rs.getInt("start_price");
	int bidIncrement = rs.getInt("bid_increment");
	String itemTitle = rs.getString("item_title");
	String itemDesc = rs.getString("item_description");
	String category = rs.getString("category");
	String brand = rs.getString("brand");
	String condition = rs.getString("clothing_condition");
	String color = rs.getString("color");
	String size = rs.getString("size");
	Timestamp closingDate = rs.getTimestamp("closing_date");
	Integer currentBid = (Integer) rs.getObject("current_bid");
	int bidCount = rs.getInt("bid_count");
	
	int displayPrice = (currentBid != null) ? currentBid : startPrice;
	String rowClass = "closed".equals(status) ? "class='closed'" : "";
%>

<tr <%=rowClass%>>
	<td><%=auctionId%></td>
	<td><%=status%></td>
	<td><%=itemTitle%></td>
	<td><%=itemDesc%></td>
	<td><%=category%></td>
	<td><%=brand%></td>
	<td><%=condition%></td>
	<td><%=color%></td>
	<td><%=size%></td>
	<td>$<%=startPrice%></td>
	<td>$<%=displayPrice%></td>
	<td>$<%=bidIncrement%></td>
	<td><%=bidCount%></td>
	<td><%=closingDate%></td>
	<td>
		<a href='deleteAuctionCustomerRep.jsp?auction_id=<%=auctionId%>'>[Delete Auction]</a>
		<br>
		<a href='deleteBidsCustomerRep.jsp?auction_id=<%=auctionId%>'>[Delete Bids]</a>
		
	</td>
</tr>

<%
}

if (!hasAuctions) {
%>
<tr>
	<td colspan="15">No auctions available.</td>
</tr>
<%
}

con.close();

} catch (Exception e) {
	out.println("Error: " + e.getMessage());
}
%>

</table>

</body>
</html>
