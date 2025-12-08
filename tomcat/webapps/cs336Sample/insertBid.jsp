<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Process Bid</title>
</head>
<body>
<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>

<%
String auctionIdStr = request.getParameter("auction_id");
String bidAmountStr = request.getParameter("bid_amount");
String currentUser = "" + session.getAttribute("user");

try {
	int auctionId = Integer.parseInt(auctionIdStr);
	int bidAmount = Integer.parseInt(bidAmountStr);
	
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();
	
	con.setAutoCommit(false);
	
	String checkAuction = "SELECT start_price, bid_increment, seller, " +
			"(SELECT MAX(amount) FROM bids WHERE auction_id = ?) as current_bid " +
			"FROM auction WHERE auction_id = ? AND auction_status = 'active';";
	PreparedStatement ps1 = con.prepareStatement(checkAuction);
	ps1.setInt(1, auctionId);
	ps1.setInt(2, auctionId);
	ResultSet rs = ps1.executeQuery();
	
	if (rs.next()) {
		int startPrice = rs.getInt("start_price");
		int bidIncrement = rs.getInt("bid_increment");
		String seller = rs.getString("seller");
		Integer currentBid = (Integer) rs.getObject("current_bid");
		int minBid = (currentBid != null) ? currentBid + bidIncrement : startPrice;
		
		if (seller.equals(currentUser)) {
			out.println("<p style='color:red;'>Error: You cannot bid on your own auction.</p>");
			con.rollback();
		} else if (bidAmount < minBid) {
			out.println("<p style='color:red;'>Error: Bid amount must be at least $" + minBid + "</p>");
			con.rollback();
		} else {
			String insertBid = "INSERT INTO bids (auction_id, username, amount, bid_time) VALUES (?, ?, ?, NOW());";
			PreparedStatement ps2 = con.prepareStatement(insertBid);
			ps2.setInt(1, auctionId);
			ps2.setString(2, currentUser);
			ps2.setInt(3, bidAmount);
			ps2.executeUpdate();
			
			String getPreviousBidders = "SELECT DISTINCT username FROM bids WHERE auction_id = ? AND username != ?;";
			PreparedStatement ps3 = con.prepareStatement(getPreviousBidders);
			ps3.setInt(1, auctionId);
			ps3.setString(2, currentUser);
			ResultSet bidders = ps3.executeQuery();
			
			String insertAlert = "INSERT INTO alerts (username, message) VALUES (?, ?);";
			PreparedStatement ps4 = con.prepareStatement(insertAlert);
			
			while (bidders.next()) {
				String bidderUsername = bidders.getString("username");
				String message = "A higher bid of $" + bidAmount + " has been placed on auction #" + auctionId;
				ps4.setString(1, bidderUsername);
				ps4.setString(2, message);
				ps4.executeUpdate();
			}
			
			String checkAutoBids = "SELECT username, upper_limit, bid_increment FROM auto_bids " +
					"WHERE auction_id = ? AND username != ? AND upper_limit > ?;";
			PreparedStatement ps5 = con.prepareStatement(checkAutoBids);
			ps5.setInt(1, auctionId);
			ps5.setString(2, currentUser);
			ps5.setInt(3, bidAmount);
			ResultSet autoBids = ps5.executeQuery();
			
			int highestAutoBid = bidAmount;
			String highestAutoBidder = null;
			
			while (autoBids.next()) {
				String autoBidder = autoBids.getString("username");
				int upperLimit = autoBids.getInt("upper_limit");
				int autoIncrement = autoBids.getInt("bid_increment");
				
				int newAutoBid = Math.min(highestAutoBid + autoIncrement, upperLimit);
				
				if (newAutoBid > highestAutoBid) {
					highestAutoBid = newAutoBid;
					highestAutoBidder = autoBidder;
				}
			}
			
			if (highestAutoBidder != null) {
				String insertAutoBid = "INSERT INTO bids (auction_id, username, amount, bid_time) VALUES (?, ?, ?, NOW());";
				PreparedStatement ps6 = con.prepareStatement(insertAutoBid);
				ps6.setInt(1, auctionId);
				ps6.setString(2, highestAutoBidder);
				ps6.setInt(3, highestAutoBid);
				ps6.executeUpdate();
				
				String notifyOutbid = "INSERT INTO alerts (username, message) VALUES (?, ?);";
				PreparedStatement ps7 = con.prepareStatement(notifyOutbid);
				ps7.setString(1, currentUser);
				ps7.setString(2, "You have been automatically outbid on auction #" + auctionId + 
						". New bid: $" + highestAutoBid);
				ps7.executeUpdate();
			}
			
			con.commit();
			
			out.println("<p style='color:green;'>Bid placed successfully!</p>");
			out.println("<p>Your bid: $" + bidAmount + "</p>");
			if (highestAutoBidder != null) {
				out.println("<p>An automatic bid of $" + highestAutoBid + " was placed by another bidder.</p>");
			}
			out.println("<p>Redirecting to auctions page...</p>");
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
