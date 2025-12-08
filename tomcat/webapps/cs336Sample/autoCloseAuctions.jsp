<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%
// Silently close any expired auctions
try {
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();
	
	con.setAutoCommit(false);
	
	String getExpiredAuctions = "SELECT auction_id, seller, hidden_min_price, item_title FROM auction " +
			"WHERE auction_status = 'active' AND closing_date <= NOW();";
	PreparedStatement ps1 = con.prepareStatement(getExpiredAuctions);
	ResultSet rs = ps1.executeQuery();
	
	while (rs.next()) {
		int auctionId = rs.getInt("auction_id");
		String seller = rs.getString("seller");
		int hiddenMinPrice = rs.getInt("hidden_min_price");
		String itemTitle = rs.getString("item_title");
		
		String getHighestBid = "SELECT username, amount FROM bids WHERE auction_id = ? " +
				"ORDER BY amount DESC, bid_time ASC LIMIT 1;";
		PreparedStatement ps2 = con.prepareStatement(getHighestBid);
		ps2.setInt(1, auctionId);
		ResultSet bidRs = ps2.executeQuery();
		
		String winner = null;
		int winningBid = 0;
		
		if (bidRs.next()) {
			String highestBidder = bidRs.getString("username");
			int highestBid = bidRs.getInt("amount");
			
			if (highestBid >= hiddenMinPrice) {
				winner = highestBidder;
				winningBid = highestBid;
			}
		}
		
		String closeAuction = "UPDATE auction SET auction_status = 'closed' WHERE auction_id = ?;";
		PreparedStatement ps3 = con.prepareStatement(closeAuction);
		ps3.setInt(1, auctionId);
		ps3.executeUpdate();
		
		String insertAlert = "INSERT INTO alerts (username, message) VALUES (?, ?);";
		PreparedStatement ps4 = con.prepareStatement(insertAlert);
		
		if (winner != null) {
			String winnerMessage = "Congratulations! You won auction #" + auctionId + 
					" (" + itemTitle + ") with a bid of $" + winningBid;
			ps4.setString(1, winner);
			ps4.setString(2, winnerMessage);
			ps4.executeUpdate();
			
			String sellerMessage = "Your auction #" + auctionId + " (" + itemTitle + ") has closed. " +
					"Winner: " + winner + " with bid of $" + winningBid;
			ps4.setString(1, seller);
			ps4.setString(2, sellerMessage);
			ps4.executeUpdate();
		} else {
			String sellerMessage = "Your auction #" + auctionId + " (" + itemTitle + ") has closed " +
					"with no winner (reserve price not met).";
			ps4.setString(1, seller);
			ps4.setString(2, sellerMessage);
			ps4.executeUpdate();
		}
		
		String notifyLosers = "SELECT DISTINCT username FROM bids WHERE auction_id = ? AND username != ?;";
		PreparedStatement ps5 = con.prepareStatement(notifyLosers);
		ps5.setInt(1, auctionId);
		ps5.setString(2, winner != null ? winner : "");
		ResultSet losers = ps5.executeQuery();
		
		while (losers.next()) {
			String loser = losers.getString("username");
			String loserMessage = "Auction #" + auctionId + " (" + itemTitle + ") has closed. " +
					(winner != null ? "Winner: " + winner : "No winner (reserve not met)");
			ps4.setString(1, loser);
			ps4.setString(2, loserMessage);
			ps4.executeUpdate();
		}
	}
	
	con.commit();
	con.setAutoCommit(true);
	db.closeConnection(con);
	
} catch (Exception e) {
	// Silently fail - don't disrupt the page
}
%>
