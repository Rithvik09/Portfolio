<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete Bids</title>
<style>
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    /* .highest { background-color: #d4edda; font-weight: bold; } */
</style>
</head>
<body>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='manageAuctionsCustomerRep.jsp'>[Back to All Auctions]</a> <br><br>

<%


try {
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    
   	String str = "SELECT item_title FROM auction WHERE auction_id = ?;";
   	String auctionId = request.getParameter("auction_id");
    PreparedStatement ps = con.prepareStatement(str);
    ps.setString(1, auctionId);
    ResultSet rs = ps.executeQuery();
    
    String itemTitle = "";
    
    if (rs.next()) {
    	itemTitle = rs.getString("item_title");
%>

<h2>Auction #<%=auctionId%>: <%=itemTitle%></h2>

<h3>Bid History</h3>

<%
        String getBids = "SELECT bid_id, username, amount, bid_time FROM bids " +
                        "WHERE auction_id = ? ORDER BY amount DESC, bid_time ASC;";
        PreparedStatement ps2 = con.prepareStatement(getBids);
        ps2.setString(1, auctionId);
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
        <th>Delete Bid</th>
    </tr>

<%
        int rank = 1;
        while (rs2.next()) {
            hasBids = true;
            int bidId = rs2.getInt("bid_id");
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
        <td><a href="deleteSingleBid.jsp?bid_id=<%=bidId%>">[Delete Bid]</a>
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
        ps3.setInt(1, Integer.parseInt(auctionId));
        ResultSet rs3 = ps3.executeQuery();
        
        boolean hasAutoBids = false;
    }
}catch (Exception e){
	out.println(e);
}
%>

</body>
</html>
