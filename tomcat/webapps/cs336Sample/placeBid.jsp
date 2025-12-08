<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Place Bid</title>
</head>
<body>
<%@ page import="java.sql.*" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='viewAllAuctions.jsp'>[Back to All Auctions]</a> <br> <br>

<%
String auctionIdStr = request.getParameter("auction_id");
int auctionId = Integer.parseInt(auctionIdStr);
String currentUser = "" + session.getAttribute("user");

try {
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    
    String sql = "SELECT a.auction_id, a.seller, a.start_price, a.bid_increment, a.closing_date, " +
    		"a.item_title, a.item_description, a.category, a.brand, a.clothing_condition, " +
    		"a.color, a.size, " +
    		"(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as current_bid " +
    		"FROM auction a WHERE a.auction_id = ? AND a.auction_status = 'active';";
    
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, auctionId);
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
    	int startPrice = rs.getInt("start_price");
    	int bidIncrement = rs.getInt("bid_increment");
    	Integer currentBid = (Integer) rs.getObject("current_bid");
    	int minBid = (currentBid != null) ? currentBid + bidIncrement : startPrice;
    	
    	String itemTitle = rs.getString("item_title");
    	String itemDesc = rs.getString("item_description");
    	String category = rs.getString("category");
    	String brand = rs.getString("brand");
    	String condition = rs.getString("clothing_condition");
    	String color = rs.getString("color");
    	String size = rs.getString("size");
    	Timestamp closingDate = rs.getTimestamp("closing_date");
%>

<h2>Place Bid on: <%=itemTitle%></h2>

<h3>Auction Details</h3>
<table border="1">
	<tr><td><strong>Item:</strong></td><td><%=itemTitle%></td></tr>
	<tr><td><strong>Description:</strong></td><td><%=itemDesc%></td></tr>
	<tr><td><strong>Category:</strong></td><td><%=category%></td></tr>
	<tr><td><strong>Brand:</strong></td><td><%=brand%></td></tr>
	<tr><td><strong>Condition:</strong></td><td><%=condition%></td></tr>
	<tr><td><strong>Color:</strong></td><td><%=color%></td></tr>
	<tr><td><strong>Size:</strong></td><td><%=size%></td></tr>
	<tr><td><strong>Starting Price:</strong></td><td>$<%=startPrice%></td></tr>
	<tr><td><strong>Current Bid:</strong></td><td>$<%=(currentBid != null) ? currentBid : startPrice%></td></tr>
	<tr><td><strong>Bid Increment:</strong></td><td>$<%=bidIncrement%></td></tr>
	<tr><td><strong>Closing Date:</strong></td><td><%=closingDate%></td></tr>
</table>

<br><br>

<h3>Manual Bid</h3>
<form id="manualBidForm" action="insertBid.jsp" method="POST">
	<input type="hidden" name="auction_id" value="<%=auctionId%>"/>
	<input type="hidden" name="bid_type" value="manual"/>
	Bid Amount: $<input type="number" name="bid_amount" min="<%=minBid%>" required/> 
	(Minimum: $<%=minBid%>)<br><br>
	<button type="submit">Place Bid</button>
	<p id="errorMessage" style="color:red;"></p>
</form>

<br><br>

<h3>Automatic Bidding</h3>
<form id="autoBidForm" action="insertAutoBid.jsp" method="POST">
	<input type="hidden" name="auction_id" value="<%=auctionId%>"/>
	Upper Limit: $<input type="number" name="upper_limit" min="<%=minBid%>" required/><br><br>
	Bid Increment: $<input type="number" name="bid_increment" value="<%=bidIncrement%>" min="1" required/><br><br>
	<button type="submit">Set Automatic Bidding</button>
	<p id="autoErrorMessage" style="color:red;"></p>
</form>

<script>
document.getElementById("manualBidForm").addEventListener("submit", function(event){
	const form = event.target;
	const error = document.getElementById("errorMessage");
	error.textContent = "";
	
	const bidAmount = parseInt(form.elements["bid_amount"].value);
	const minBid = <%=minBid%>;
	
	if (bidAmount < minBid) {
		error.textContent = "Error: Bid must be at least $" + minBid;
		event.preventDefault();
	}
});

document.getElementById("autoBidForm").addEventListener("submit", function(event){
	const form = event.target;
	const error = document.getElementById("autoErrorMessage");
	error.textContent = "";
	
	const upperLimit = parseInt(form.elements["upper_limit"].value);
	const minBid = <%=minBid%>;
	
	if (upperLimit < minBid) {
		error.textContent = "Error: Upper limit must be at least $" + minBid;
		event.preventDefault();
	}
});
</script>

<%
    } else {
    	out.println("<p>Auction not found or not active.</p>");
    }
    
    con.close();
    
} catch (Exception e) {
	out.println("Error: " + e.getMessage());
}
%>

</body>
</html>
