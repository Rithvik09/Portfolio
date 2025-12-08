<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Auction Details</title>
<style>
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .details { background-color: #f9f9f9; padding: 15px; margin: 15px 0; border-radius: 5px; }
    .highest { background-color: #d4edda; font-weight: bold; }
</style>
</head>
<body>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='viewAllAuctions.jsp'>[Back to All Auctions]</a> <br><br>

<%
String auctionIdStr = request.getParameter("auction_id");
if (auctionIdStr == null) {
    out.println("<p style='color:red;'>No auction specified.</p>");
    return;
}

int auctionId = Integer.parseInt(auctionIdStr);

try {
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    
    String getAuction = "SELECT a.auction_id, a.seller, a.auction_status, a.start_price, " +
                       "a.bid_increment, a.hidden_min_price, a.closing_date, a.item_title, " +
                       "a.item_description, a.category, a.brand, a.clothing_condition, " +
                       "a.color, a.size FROM auction a WHERE a.auction_id = ?;";
    
    PreparedStatement ps1 = con.prepareStatement(getAuction);
    ps1.setInt(1, auctionId);
    ResultSet rs1 = ps1.executeQuery();
    
    if (rs1.next()) {
        String itemTitle = rs1.getString("item_title");
        String itemDesc = rs1.getString("item_description");
        String seller = rs1.getString("seller");
        String status = rs1.getString("auction_status");
        int startPrice = rs1.getInt("start_price");
        int bidIncrement = rs1.getInt("bid_increment");
        int hiddenMin = rs1.getInt("hidden_min_price");
        Timestamp closingDate = rs1.getTimestamp("closing_date");
        String category = rs1.getString("category");
        String brand = rs1.getString("brand");
        String condition = rs1.getString("clothing_condition");
        String color = rs1.getString("color");
        String size = rs1.getString("size");
%>

<h2>Auction #<%=auctionId%>: <%=itemTitle%></h2>

<div class="details">
    <h3>Item Details</h3>
    <p><strong>Description:</strong> <%=itemDesc%></p>
    <p><strong>Category:</strong> <%=category%> | <strong>Brand:</strong> <%=brand%></p>
    <p><strong>Condition:</strong> <%=condition%> | <strong>Color:</strong> <%=color%> | <strong>Size:</strong> <%=size%></p>
    <p><strong>Seller:</strong> <%=seller%></p>
    <p><strong>Status:</strong> <%=status%></p>
    <p><strong>Starting Price:</strong> $<%=startPrice%></p>
    <p><strong>Bid Increment:</strong> $<%=bidIncrement%></p>
    <p><strong>Closing Date:</strong> <%=closingDate%></p>
</div>

<h3>Bid History</h3>

<%
        String getBids = "SELECT bid_id, username, amount, bid_time FROM bids " +
                        "WHERE auction_id = ? ORDER BY amount DESC, bid_time ASC;";
        PreparedStatement ps2 = con.prepareStatement(getBids);
        ps2.setInt(1, auctionId);
        ResultSet rs2 = ps2.executeQuery();
        
        boolean hasBids = false;
        boolean firstBid = true;
%>

<table>
    <tr>
        <th>Rank</th>
        <th>Bidder</th>
        <th>Bid Amount</th>
        <th>Bid Time</th>
    </tr>

<%
        int rank = 1;
        while (rs2.next()) {
            hasBids = true;
            String bidder = rs2.getString("username");
            int amount = rs2.getInt("amount");
            Timestamp bidTime = rs2.getTimestamp("bid_time");
            String rowClass = firstBid ? "highest" : "";
            firstBid = false;
%>

    <tr class="<%=rowClass%>">
        <td><%=rank%></td>
        <td><%=bidder%></td>
        <td>$<%=amount%></td>
        <td><%=bidTime%></td>
    </tr>

<%
            rank++;
        }
        
        if (!hasBids) {
%>
    <tr>
        <td colspan="4">No bids placed yet.</td>
    </tr>
<%
        }
%>

</table>

<%
        String getAutoBids = "SELECT username, upper_limit, bid_increment FROM auto_bids " +
                            "WHERE auction_id = ?;";
        PreparedStatement ps3 = con.prepareStatement(getAutoBids);
        ps3.setInt(1, auctionId);
        ResultSet rs3 = ps3.executeQuery();
        
        boolean hasAutoBids = false;
%>

<h3>Active Automatic Bidding</h3>
<table>
    <tr>
        <th>Bidder</th>
        <th>Upper Limit</th>
        <th>Increment</th>
    </tr>

<%
        while (rs3.next()) {
            hasAutoBids = true;
            String autoBidder = rs3.getString("username");
            int upperLimit = rs3.getInt("upper_limit");
            int increment = rs3.getInt("bid_increment");
%>

    <tr>
        <td><%=autoBidder%></td>
        <td>$<%=upperLimit%></td>
        <td>$<%=increment%></td>
    </tr>

<%
        }
        
        if (!hasAutoBids) {
%>
    <tr>
        <td colspan="3">No automatic bidding configured.</td>
    </tr>
<%
        }
%>

</table>

<br>
<% if ("active".equals(status)) { %>
    <a href='placeBid.jsp?auction_id=<%=auctionId%>'>[Place a Bid]</a>
<% } %>
<a href='viewSimilarItems.jsp?auction_id=<%=auctionId%>' style='margin-left: 10px;'>[View Similar Items]</a>

<%
    } else {
        out.println("<p style='color:red;'>Auction not found.</p>");
    }
    
    db.closeConnection(con);
    
} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
