<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Similar Items</title>
<style>
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .similar { background-color: #e7f3ff; }
    .details { background-color: #f9f9f9; padding: 15px; margin: 15px 0; border-radius: 5px; }
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
    
    // Get the current auction details
    String getCurrentAuction = "SELECT category, brand, size, color, item_title FROM auction WHERE auction_id = ?;";
    PreparedStatement psCurrent = con.prepareStatement(getCurrentAuction);
    psCurrent.setInt(1, auctionId);
    ResultSet rsCurrent = psCurrent.executeQuery();
    
    if (!rsCurrent.next()) {
        out.println("<p style='color:red;'>Auction not found.</p>");
        db.closeConnection(con);
        return;
    }
    
    String category = rsCurrent.getString("category");
    String brand = rsCurrent.getString("brand");
    String size = rsCurrent.getString("size");
    String color = rsCurrent.getString("color");
    String itemTitle = rsCurrent.getString("item_title");
%>

<div class="details">
    <h3>Finding items similar to: <%=itemTitle%></h3>
    <p><strong>Category:</strong> <%=category%> | <strong>Brand:</strong> <%=brand%> | <strong>Size:</strong> <%=size%> | <strong>Color:</strong> <%=color%></p>
</div>

<h3>Similar Items from Past Month</h3>

<%
    // Find similar items from the past month
    // Similarity: same category OR (same brand AND same size) OR (same category AND same color)
    // From auctions that closed in the past month
    String sql = "SELECT a.auction_id, a.auction_status, a.seller, a.start_price, a.bid_increment, " +
            "a.closing_date, a.item_title, a.item_description, a.category, a.brand, " +
            "a.clothing_condition, a.color, a.size, " +
            "(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as final_bid, " +
            "(SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id) as bid_count " +
            "FROM auction a " +
            "WHERE a.auction_id != ? " +
            "AND a.auction_status = 'closed' " +
            "AND a.closing_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH) " +
            "AND (" +
            "    (a.category = ?) OR " +
            "    (a.brand = ? AND a.size = ?) OR " +
            "    (a.category = ? AND a.color = ?) OR " +
            "    (a.brand = ? AND a.color = ?)" +
            ") " +
            "ORDER BY " +
            "    CASE WHEN a.category = ? AND a.brand = ? AND a.size = ? AND a.color = ? THEN 1 " +
            "         WHEN a.category = ? AND a.brand = ? THEN 2 " +
            "         WHEN a.category = ? THEN 3 " +
            "         ELSE 4 END, " +
            "    a.closing_date DESC " +
            "LIMIT 20;";
    
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, auctionId);
    ps.setString(2, category);
    ps.setString(3, brand);
    ps.setString(4, size);
    ps.setString(5, category);
    ps.setString(6, color);
    ps.setString(7, brand);
    ps.setString(8, color);
    ps.setString(9, category);
    ps.setString(10, brand);
    ps.setString(11, size);
    ps.setString(12, color);
    ps.setString(13, category);
    ps.setString(14, brand);
    ps.setString(15, category);
    
    ResultSet rs = ps.executeQuery();
    
    boolean hasSimilar = false;
%>

<table>
    <tr>
        <th>Auction ID</th>
        <th>Item</th>
        <th>Description</th>
        <th>Category</th>
        <th>Brand</th>
        <th>Size</th>
        <th>Color</th>
        <th>Condition</th>
        <th>Final Bid</th>
        <th>Total Bids</th>
        <th>Closing Date</th>
        <th>Action</th>
    </tr>

<% 
    while (rs.next()) {
        hasSimilar = true;
        int similarAuctionId = rs.getInt("auction_id");
        String similarStatus = rs.getString("auction_status");
        String similarSeller = rs.getString("seller");
        int similarStartPrice = rs.getInt("start_price");
        String similarItemTitle = rs.getString("item_title");
        String similarItemDesc = rs.getString("item_description");
        String similarCategory = rs.getString("category");
        String similarBrand = rs.getString("brand");
        String similarCondition = rs.getString("clothing_condition");
        String similarColor = rs.getString("color");
        String similarSize = rs.getString("size");
        Timestamp similarClosingDate = rs.getTimestamp("closing_date");
        Integer finalBid = (Integer) rs.getObject("final_bid");
        int bidCount = rs.getInt("bid_count");
        
        int displayPrice = (finalBid != null) ? finalBid : similarStartPrice;
        
        // Calculate similarity score for display
        int matchCount = 0;
        if (similarCategory != null && similarCategory.equals(category)) matchCount++;
        if (similarBrand != null && similarBrand.equals(brand)) matchCount++;
        if (similarSize != null && similarSize.equals(size)) matchCount++;
        if (similarColor != null && similarColor.equals(color)) matchCount++;
%>

    <tr class="similar">
        <td><%=similarAuctionId%></td>
        <td><%=similarItemTitle%> <small>(<%=matchCount%>/4 matches)</small></td>
        <td><%=similarItemDesc%></td>
        <td><%=similarCategory%></td>
        <td><%=similarBrand%></td>
        <td><%=similarSize%></td>
        <td><%=similarColor%></td>
        <td><%=similarCondition%></td>
        <td>$<%=displayPrice%></td>
        <td><%=bidCount%></td>
        <td><%=similarClosingDate%></td>
        <td>
            <a href='viewAuctionDetails.jsp?auction_id=<%=similarAuctionId%>'>[View Details]</a>
        </td>
    </tr>

<%
    }
    
    if (!hasSimilar) {
%>
    <tr>
        <td colspan="12">No similar items found in the past month.</td>
    </tr>
<%
    }
    
    db.closeConnection(con);
    
} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>
</table>

</body>
</html>

