<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>All Auctions</title>
<style>
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .closed { background-color: #ffcccc; }
</style>
</head>
<body>
<%@ page import="java.sql.*" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='success.jsp'>[Return to Home Page]</a> 
<a href='searchAuctions.jsp' style='margin-left: 20px;'>[Advanced Search]</a>
<br> <br>

<% 
String currentUser = "" + session.getAttribute("user");

// Get sort parameter
String sortBy = request.getParameter("sort");
String sortOrder = request.getParameter("order");
if (sortBy == null || sortBy.isEmpty()) {
    sortBy = "closing_date";
}
if (sortOrder == null || sortOrder.isEmpty()) {
    sortOrder = "DESC";
}

try {
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    
    // Build ORDER BY clause based on sort parameter
    String orderByClause = "ORDER BY ";
    switch(sortBy) {
        case "category":
            orderByClause += "a.category " + sortOrder;
            break;
        case "current_bid":
            orderByClause += "COALESCE((SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id), a.start_price) " + sortOrder;
            break;
        case "start_price":
            orderByClause += "a.start_price " + sortOrder;
            break;
        case "bid_count":
            orderByClause += "bid_count " + sortOrder;
            break;
        case "item_title":
            orderByClause += "a.item_title " + sortOrder;
            break;
        case "closing_date":
        default:
            orderByClause += "a.closing_date " + sortOrder;
            break;
    }
    
    String sql = "SELECT a.auction_id, a.auction_status, a.seller, a.start_price, a.bid_increment, " + 
    		"a.closing_date, a.item_title, a.item_description, a.category, a.brand, " + 
    		"a.clothing_condition, a.color, a.size, " +
    		"(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as current_bid, " +
    		"(SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id) as bid_count " +
    		"FROM auction a " + orderByClause + ";";
    
    PreparedStatement ps = con.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
    
    boolean hasAuctions = false;
%>

<h2>All Auctions</h2>

<div style="margin: 10px 0;">
    <strong>Sort by:</strong>
    <a href="viewAllAuctions.jsp?sort=closing_date&order=DESC">Closing Date (Newest)</a> |
    <a href="viewAllAuctions.jsp?sort=closing_date&order=ASC">Closing Date (Oldest)</a> |
    <a href="viewAllAuctions.jsp?sort=category&order=ASC">Category</a> |
    <a href="viewAllAuctions.jsp?sort=current_bid&order=DESC">Price (High to Low)</a> |
    <a href="viewAllAuctions.jsp?sort=current_bid&order=ASC">Price (Low to High)</a> |
    <a href="viewAllAuctions.jsp?sort=start_price&order=ASC">Start Price</a> |
    <a href="viewAllAuctions.jsp?sort=bid_count&order=DESC">Most Bids</a> |
    <a href="viewAllAuctions.jsp?sort=item_title&order=ASC">Item Name</a>
</div>

<table>
	<tr>
		<th>Auction ID</th>
		<th>Status</th>
		<th>Item</th>
		<th>Description</th>
		<th><a href="viewAllAuctions.jsp?sort=category&order=ASC">Category</a></th>
		<th>Brand</th>
		<th>Condition</th>
		<th>Color</th>
		<th>Size</th>
		<th><a href="viewAllAuctions.jsp?sort=start_price&order=ASC">Start Price</a></th>
		<th><a href="viewAllAuctions.jsp?sort=current_bid&order=DESC">Current Bid</a></th>
		<th>Bid Increment</th>
		<th><a href="viewAllAuctions.jsp?sort=bid_count&order=DESC">Total Bids</a></th>
		<th><a href="viewAllAuctions.jsp?sort=closing_date&order=DESC">Closing Date</a></th>
		<th>Action</th>
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
		<a href='viewAuctionDetails.jsp?auction_id=<%=auctionId%>'>[Details]</a>
		<% if ("active".equals(status) && !seller.equals(currentUser)) { %>
			<a href='placeBid.jsp?auction_id=<%=auctionId%>'>[Bid]</a>
		<% } else if ("active".equals(status) && seller.equals(currentUser)) { %>
			Your auction
		<% } else { %>
			Closed
		<% } %>
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
