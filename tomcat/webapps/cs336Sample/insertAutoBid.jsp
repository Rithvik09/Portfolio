<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Setup Automatic Bidding</title>
</head>
<body>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
String auctionIdStr = request.getParameter("auction_id");
String upperLimitStr = request.getParameter("upper_limit");
String bidIncrementStr = request.getParameter("bid_increment");
String currentUser = "" + session.getAttribute("user");

try {
	int auctionId = Integer.parseInt(auctionIdStr);
	int upperLimit = Integer.parseInt(upperLimitStr);
	int bidIncrement = Integer.parseInt(bidIncrementStr);
	
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();
	
	con.setAutoCommit(false);
	
	String checkAuction = "SELECT start_price, bid_increment as auction_increment, seller, " +
			"(SELECT MAX(amount) FROM bids WHERE auction_id = ?) as current_bid, " +
			"(SELECT username FROM bids WHERE auction_id = ? ORDER BY amount DESC, bid_time ASC LIMIT 1) as highest_bidder " +
			"FROM auction WHERE auction_id = ? AND auction_status = 'active';";
	PreparedStatement ps1 = con.prepareStatement(checkAuction);
	ps1.setInt(1, auctionId);
	ps1.setInt(2, auctionId);
	ps1.setInt(3, auctionId);
	ResultSet rs = ps1.executeQuery();
	
	if (rs.next()) {
		int startPrice = rs.getInt("start_price");
		int auctionIncrement = rs.getInt("auction_increment");
		String seller = rs.getString("seller");
		Integer currentBid = (Integer) rs.getObject("current_bid");
		String highestBidder = rs.getString("highest_bidder");
		int minRequired = (currentBid != null) ? currentBid : startPrice;
		
		if (seller.equals(currentUser)) {
			out.println("<p style='color:red;'>Error: You cannot bid on your own auction.</p>");
			con.rollback();
		} else if (upperLimit < minRequired) {
			out.println("<p style='color:red;'>Error: Upper limit must be at least $" + minRequired + "</p>");
			con.rollback();
		} else {
			String checkExisting = "SELECT * FROM auto_bids WHERE auction_id = ? AND username = ?;";
			PreparedStatement ps2 = con.prepareStatement(checkExisting);
			ps2.setInt(1, auctionId);
			ps2.setString(2, currentUser);
			ResultSet existing = ps2.executeQuery();
			
			if (existing.next()) {
				String updateAutoBid = "UPDATE auto_bids SET upper_limit = ?, bid_increment = ? " +
						"WHERE auction_id = ? AND username = ?;";
				PreparedStatement ps3 = con.prepareStatement(updateAutoBid);
				ps3.setInt(1, upperLimit);
				ps3.setInt(2, bidIncrement);
				ps3.setInt(3, auctionId);
				ps3.setString(4, currentUser);
				ps3.executeUpdate();
				
				out.println("<p style='color:green;'>Automatic bidding updated!</p>");
			} else {
				String insertAutoBid = "INSERT INTO auto_bids (auction_id, username, upper_limit, bid_increment) " +
						"VALUES (?, ?, ?, ?);";
				PreparedStatement ps3 = con.prepareStatement(insertAutoBid);
				ps3.setInt(1, auctionId);
				ps3.setString(2, currentUser);
				ps3.setInt(3, upperLimit);
				ps3.setInt(4, bidIncrement);
				ps3.executeUpdate();
				
				out.println("<p style='color:green;'>Automatic bidding set successfully!</p>");
			}
			
			// Immediately place a bid if upper limit is higher than current bid and we're not already the highest bidder
			if (currentBid != null && upperLimit > currentBid && !currentUser.equals(highestBidder)) {
				int myBid = currentBid + auctionIncrement;
				
				String insertBid = "INSERT INTO bids (auction_id, username, amount, bid_time) VALUES (?, ?, ?, NOW());";
				PreparedStatement ps4 = con.prepareStatement(insertBid);
				ps4.setInt(1, auctionId);
				ps4.setString(2, currentUser);
				ps4.setInt(3, myBid);
				ps4.executeUpdate();
				
				// Alert previous highest bidder
				if (highestBidder != null) {
					String alertPrevious = "INSERT INTO alerts (username, message) VALUES (?, ?);";
					PreparedStatement ps5 = con.prepareStatement(alertPrevious);
					ps5.setString(1, highestBidder);
					ps5.setString(2, "You have been outbid on auction #" + auctionId + ". New bid: $" + myBid);
					ps5.executeUpdate();
				}
				
				out.println("<p style='color:green;'>✓ Immediate bid placed: $" + myBid + "</p>");
			} else if (currentBid == null && upperLimit >= startPrice) {
				// No bids yet, place starting bid
				String insertBid = "INSERT INTO bids (auction_id, username, amount, bid_time) VALUES (?, ?, ?, NOW());";
				PreparedStatement ps4 = con.prepareStatement(insertBid);
				ps4.setInt(1, auctionId);
				ps4.setString(2, currentUser);
				ps4.setInt(3, startPrice);
				ps4.executeUpdate();
				
				out.println("<p style='color:green;'>✓ Initial bid placed: $" + startPrice + "</p>");
			} else if (currentUser.equals(highestBidder)) {
				out.println("<p>You are already the highest bidder.</p>");
			}
			
			out.println("<p>Upper Limit: $" + upperLimit + "</p>");
			out.println("<p>Bid Increment: $" + bidIncrement + "</p>");
			out.println("<p>You will be automatically outbid if someone exceeds your upper limit.</p>");
			out.println("<p>Redirecting to auctions page...</p>");
			
			con.commit();
			response.setHeader("Refresh", "5; URL=viewAllAuctions.jsp");
		}
	} else {
		out.println("<p style='color:red;'>Error: Auction not found or not active.</p>");
		con.rollback();
	}
	
	con.setAutoCommit(true);
	db.closeConnection(con);
	
} catch (Exception e) {
	out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
}
%>

<br><br>
<a href='viewAllAuctions.jsp'>[Back to All Auctions]</a>

</body>
</html>
