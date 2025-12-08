<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Search Auctions</title>
<style>
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .closed { background-color: #ffcccc; }
    .search-form { background-color: #f9f9f9; padding: 20px; margin: 20px 0; border-radius: 5px; }
    .form-group { margin: 10px 0; }
    label { display: inline-block; width: 150px; }
    input, select { padding: 5px; width: 200px; }
</style>
</head>
<body>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="autoCloseAuctions.jsp" %>

<a href='success.jsp'>[Return to Home Page]</a>
<a href='viewAllAuctions.jsp' style='margin-left: 20px;'>[View All Auctions]</a>
<br><br>

<h2>Advanced Search</h2>

<div class="search-form">
<form method="GET" action="searchAuctions.jsp">
    <div class="form-group">
        <label>Item Title:</label>
        <input type="text" name="item_title" placeholder="Search in title...">
    </div>
    
    <div class="form-group">
        <label>Category:</label>
        <select name="category">
            <option value="">Any</option>
            <option value="shirt">Shirt</option>
            <option value="pants">Pants</option>
            <option value="hoodie">Hoodie</option>
        </select>
    </div>
    
    <div class="form-group">
        <label>Brand:</label>
        <input type="text" name="brand" placeholder="Enter brand...">
    </div>
    
    <div class="form-group">
        <label>Size:</label>
        <select name="size">
            <option value="">Any</option>
            <option value="XS">XS</option>
            <option value="S">S</option>
            <option value="M">M</option>
            <option value="L">L</option>
            <option value="XL">XL</option>
        </select>
    </div>
    
    <div class="form-group">
        <label>Color:</label>
        <input type="text" name="color" placeholder="Enter color...">
    </div>
    
    <div class="form-group">
        <label>Condition:</label>
        <select name="condition">
            <option value="">Any</option>
            <option value="new">New</option>
            <option value="used">Used</option>
            <option value="fair">Fair</option>
        </select>
    </div>
    
    <div class="form-group">
        <label>Min Price:</label>
        <input type="number" name="min_price" placeholder="Minimum price">
    </div>
    
    <div class="form-group">
        <label>Max Price:</label>
        <input type="number" name="max_price" placeholder="Maximum price">
    </div>
    
    <div class="form-group">
        <label>Status:</label>
        <select name="status">
            <option value="">Any</option>
            <option value="active">Active Only</option>
            <option value="closed">Closed Only</option>
        </select>
    </div>
    
    <div class="form-group">
        <label>Seller:</label>
        <input type="text" name="seller" placeholder="Search by seller username...">
    </div>
    
    <div class="form-group">
        <input type="submit" value="Search" style="width: auto; padding: 10px 20px; cursor: pointer;">
        <input type="reset" value="Clear" style="width: auto; padding: 10px 20px; margin-left: 10px; cursor: pointer;">
    </div>
</form>
</div>

<%
String currentUser = "" + session.getAttribute("user");

// Get search parameters
String itemTitle = request.getParameter("item_title");
String category = request.getParameter("category");
String brand = request.getParameter("brand");
String size = request.getParameter("size");
String color = request.getParameter("color");
String condition = request.getParameter("condition");
String minPriceStr = request.getParameter("min_price");
String maxPriceStr = request.getParameter("max_price");
String status = request.getParameter("status");
String seller = request.getParameter("seller");

boolean hasSearchParams = (itemTitle != null && !itemTitle.isEmpty()) ||
                         (category != null && !category.isEmpty()) ||
                         (brand != null && !brand.isEmpty()) ||
                         (size != null && !size.isEmpty()) ||
                         (color != null && !color.isEmpty()) ||
                         (condition != null && !condition.isEmpty()) ||
                         (minPriceStr != null && !minPriceStr.isEmpty()) ||
                         (maxPriceStr != null && !maxPriceStr.isEmpty()) ||
                         (status != null && !status.isEmpty()) ||
                         (seller != null && !seller.isEmpty());

if (hasSearchParams) {
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
        
        // Build dynamic SQL query
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.auction_id, a.auction_status, a.seller, a.start_price, a.bid_increment, ");
        sql.append("a.closing_date, a.item_title, a.item_description, a.category, a.brand, ");
        sql.append("a.clothing_condition, a.color, a.size, ");
        sql.append("(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as current_bid, ");
        sql.append("(SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id) as bid_count ");
        sql.append("FROM auction a WHERE 1=1 ");
        
        List<Object> params = new ArrayList<Object>();
        
        if (itemTitle != null && !itemTitle.isEmpty()) {
            sql.append("AND a.item_title LIKE ? ");
            params.add("%" + itemTitle + "%");
        }
        
        if (category != null && !category.isEmpty()) {
            sql.append("AND a.category = ? ");
            params.add(category);
        }
        
        if (brand != null && !brand.isEmpty()) {
            sql.append("AND a.brand LIKE ? ");
            params.add("%" + brand + "%");
        }
        
        if (size != null && !size.isEmpty()) {
            sql.append("AND a.size = ? ");
            params.add(size);
        }
        
        if (color != null && !color.isEmpty()) {
            sql.append("AND a.color LIKE ? ");
            params.add("%" + color + "%");
        }
        
        if (condition != null && !condition.isEmpty()) {
            sql.append("AND a.clothing_condition = ? ");
            params.add(condition);
        }
        
        if (minPriceStr != null && !minPriceStr.isEmpty()) {
            try {
                int minPrice = Integer.parseInt(minPriceStr);
                sql.append("AND COALESCE((SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id), a.start_price) >= ? ");
                params.add(minPrice);
            } catch (NumberFormatException e) {
                // Ignore invalid number
            }
        }
        
        if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
            try {
                int maxPrice = Integer.parseInt(maxPriceStr);
                sql.append("AND COALESCE((SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id), a.start_price) <= ? ");
                params.add(maxPrice);
            } catch (NumberFormatException e) {
                // Ignore invalid number
            }
        }
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND a.auction_status = ? ");
            params.add(status);
        }
        
        if (seller != null && !seller.isEmpty()) {
            sql.append("AND a.seller LIKE ? ");
            params.add("%" + seller + "%");
        }
        
        sql.append("ORDER BY a.closing_date DESC;");
        
        PreparedStatement ps = con.prepareStatement(sql.toString());
        
        // Set parameters
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        ResultSet rs = ps.executeQuery();
        
        boolean hasAuctions = false;
%>

<h3>Search Results</h3>

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
        <th>Total Bids</th>
        <th>Closing Date</th>
        <th>Action</th>
    </tr>

<% 
        while (rs.next()) {
            hasAuctions = true;
            int auctionId = rs.getInt("auction_id");
            String auctionStatus = rs.getString("auction_status");
            String auctionSeller = rs.getString("seller");
            int startPrice = rs.getInt("start_price");
            String itemTitleResult = rs.getString("item_title");
            String itemDesc = rs.getString("item_description");
            String cat = rs.getString("category");
            String br = rs.getString("brand");
            String cond = rs.getString("clothing_condition");
            String col = rs.getString("color");
            String sz = rs.getString("size");
            Timestamp closingDate = rs.getTimestamp("closing_date");
            Integer currentBid = (Integer) rs.getObject("current_bid");
            int bidCount = rs.getInt("bid_count");
            
            int displayPrice = (currentBid != null) ? currentBid : startPrice;
            String rowClass = "closed".equals(auctionStatus) ? "class='closed'" : "";
%>

    <tr <%=rowClass%>>
        <td><%=auctionId%></td>
        <td><%=auctionStatus%></td>
        <td><%=itemTitleResult%></td>
        <td><%=itemDesc%></td>
        <td><%=cat%></td>
        <td><%=br%></td>
        <td><%=cond%></td>
        <td><%=col%></td>
        <td><%=sz%></td>
        <td>$<%=startPrice%></td>
        <td>$<%=displayPrice%></td>
        <td><%=bidCount%></td>
        <td><%=closingDate%></td>
        <td>
            <a href='viewAuctionDetails.jsp?auction_id=<%=auctionId%>'>[Details]</a>
            <% if ("active".equals(auctionStatus) && !auctionSeller.equals(currentUser)) { %>
                <a href='placeBid.jsp?auction_id=<%=auctionId%>'>[Bid]</a>
            <% } else if ("active".equals(auctionStatus) && auctionSeller.equals(currentUser)) { %>
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
        <td colspan="14">No auctions found matching your search criteria.</td>
    </tr>
<%
        }
        
        con.close();
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
}
%>
</table>

</body>
</html>

