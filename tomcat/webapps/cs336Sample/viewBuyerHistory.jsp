<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Buyer Participation History</title>
<style>
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .closed { background-color: #ffcccc; }
</style>
</head>
<body>
<%@ page import="java.sql.*" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='success.jsp'>[Return to Home Page]</a> <br><br>

<%
String currentUser = "" + session.getAttribute("user");
String targetBuyer = request.getParameter("buyer");

// If no buyer specified, use current user
if (targetBuyer == null || targetBuyer.isEmpty()) {
    targetBuyer = currentUser;
}

try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    
    // Get all unique auctions this buyer has bid on
    String sql = "SELECT DISTINCT a.auction_id, a.auction_status, a.seller, a.start_price, a.bid_increment, " +
            "a.closing_date, a.item_title, a.item_description, a.category, a.brand, " +
            "a.clothing_condition, a.color, a.size, " +
            "(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as current_bid, " +
            "(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id AND username = ?) as my_highest_bid, " +
            "(SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id AND username = ?) as my_bid_count, " +
            "(SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id) as total_bid_count " +
            "FROM auction a " +
            "INNER JOIN bids b ON a.auction_id = b.auction_id " +
            "WHERE b.username = ? " +
            "ORDER BY a.closing_date DESC;";
    
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, targetBuyer);
    ps.setString(2, targetBuyer);
    ps.setString(3, targetBuyer);
    ResultSet rs = ps.executeQuery();
    
    boolean hasAuctions = false;
%>

<h2>Buyer Participation History: <%=targetBuyer%></h2>

<table>
    <tr>
        <th>Auction ID</th>
        <th>Status</th>
        <th>Item</th>
        <th>Category</th>
        <th>Brand</th>
        <th>Size</th>
        <th>Color</th>
        <th>My Highest Bid</th>
        <th>Current Bid</th>
        <th>My Bid Count</th>
        <th>Total Bids</th>
        <th>Closing Date</th>
        <th>Action</th>
    </tr>

<% 
    while (rs.next()) {
        hasAuctions = true;
        int auctionId = rs.getInt("auction_id");
        String status = rs.getString("auction_status");
        String seller = rs.getString("seller");
        int startPrice = rs.getInt("start_price");
        String itemTitle = rs.getString("item_title");
        String category = rs.getString("category");
        String brand = rs.getString("brand");
        String color = rs.getString("color");
        String size = rs.getString("size");
        Timestamp closingDate = rs.getTimestamp("closing_date");
        Integer currentBid = (Integer) rs.getObject("current_bid");
        Integer myHighestBid = (Integer) rs.getObject("my_highest_bid");
        int myBidCount = rs.getInt("my_bid_count");
        int totalBidCount = rs.getInt("total_bid_count");
        
        int displayPrice = (currentBid != null) ? currentBid : startPrice;
        String rowClass = "closed".equals(status) ? "class='closed'" : "";
        
        // Check if this buyer is currently winning
        String statusText = "";
        if ("closed".equals(status)) {
            // Check if this buyer won
            String checkWinnerSql = "SELECT username FROM bids WHERE auction_id = ? ORDER BY amount DESC, bid_time ASC LIMIT 1;";
            PreparedStatement psWinner = con.prepareStatement(checkWinnerSql);
            psWinner.setInt(1, auctionId);
            ResultSet rsWinner = psWinner.executeQuery();
            if (rsWinner.next() && targetBuyer.equals(rsWinner.getString("username"))) {
                statusText = "WON!";
                rowClass = "class='closed' style='background-color: #90EE90;'";
            }
        } else if (myHighestBid != null && currentBid != null && myHighestBid.equals(currentBid)) {
            statusText = "Currently Winning";
            rowClass = "style='background-color: #d4edda;'";
        }
%>

    <tr <%=rowClass%>>
        <td><%=auctionId%></td>
        <td><%=status%> <%=statusText%></td>
        <td><%=itemTitle%></td>
        <td><%=category%></td>
        <td><%=brand%></td>
        <td><%=size%></td>
        <td><%=color%></td>
        <td><% if (myHighestBid != null) { %>$<%=myHighestBid%><% } else { %>-<% } %></td>
        <td>$<%=displayPrice%></td>
        <td><%=myBidCount%></td>
        <td><%=totalBidCount%></td>
        <td><%=closingDate%></td>
        <td>
            <a href='viewAuctionDetails.jsp?auction_id=<%=auctionId%>'>[Details]</a>
            <% if ("active".equals(status) && !seller.equals(currentUser)) { %>
                <a href='placeBid.jsp?auction_id=<%=auctionId%>'>[Bid]</a>
            <% } %>
        </td>
    </tr>

<%
    }
    
    if (!hasAuctions) {
%>
    <tr>
        <td colspan="13">No auctions found. This buyer has not participated in any auctions.</td>
    </tr>
<%
    }
    
    con.close();
    
} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
}
%>
</table>

</body>
</html>

