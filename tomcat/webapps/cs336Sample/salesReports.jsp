<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sales Reports</title>
<style>
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .section { margin: 30px 0; padding: 20px; background-color: #f9f9f9; border-radius: 5px; }
    h2 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
    .total { font-weight: bold; font-size: 1.2em; color: #4CAF50; }
    .nav-links { margin: 20px 0; }
</style>
</head>
<body>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%@ include file="autoCloseAuctions.jsp" %>

<div class="nav-links">
    <a href='adminPage.jsp'>[Back to Admin Page]</a>
</div>

<h1>Sales Reports</h1>

<%
try {
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    
    // Get all closed auctions with winners (where final bid >= reserve price)
    String getSalesData = "SELECT a.auction_id, a.seller, a.item_title, a.category, a.brand, " +
            "a.hidden_min_price, a.closing_date, " +
            "(SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) as final_price, " +
            "(SELECT username FROM bids WHERE auction_id = a.auction_id ORDER BY amount DESC, bid_time ASC LIMIT 1) as winner " +
            "FROM auction a " +
            "WHERE a.auction_status = 'closed' " +
            "AND EXISTS (SELECT 1 FROM bids WHERE auction_id = a.auction_id) " +
            "AND (SELECT MAX(amount) FROM bids WHERE auction_id = a.auction_id) >= a.hidden_min_price " +
            "ORDER BY a.closing_date DESC;";
    
    PreparedStatement psSales = con.prepareStatement(getSalesData);
    ResultSet rsSales = psSales.executeQuery();
    
    // Store data in memory for multiple reports
    java.util.List<java.util.Map<String, Object>> sales = new java.util.ArrayList<>();
    double totalEarnings = 0;
    
    while (rsSales.next()) {
        java.util.Map<String, Object> sale = new java.util.HashMap<>();
        sale.put("auction_id", rsSales.getInt("auction_id"));
        sale.put("seller", rsSales.getString("seller"));
        sale.put("item_title", rsSales.getString("item_title"));
        sale.put("category", rsSales.getString("category"));
        sale.put("brand", rsSales.getString("brand"));
        
        // Handle final_price which might be Long from SQL MAX()
        Object priceObj = rsSales.getObject("final_price");
        Long finalPrice = null;
        if (priceObj != null) {
            finalPrice = ((Number)priceObj).longValue();
        }
        sale.put("final_price", finalPrice);
        
        sale.put("winner", rsSales.getString("winner"));
        sale.put("closing_date", rsSales.getTimestamp("closing_date"));
        sales.add(sale);
        if (finalPrice != null) {
            totalEarnings += finalPrice;
        }
    }
%>

<!-- 1. TOTAL EARNINGS -->
<div class="section">
    <h2>1. Total Earnings</h2>
    <p class="total">Total Earnings: $<%= String.format("%.2f", totalEarnings) %></p>
    <p>Total Number of Successful Sales: <%= sales.size() %></p>
</div>

<!-- 2. EARNINGS PER ITEM -->
<div class="section">
    <h2>2. Earnings Per Item</h2>
    <table>
        <tr>
            <th>Auction ID</th>
            <th>Item Title</th>
            <th>Category</th>
            <th>Brand</th>
            <th>Seller</th>
            <th>Winner</th>
            <th>Final Price</th>
            <th>Closing Date</th>
        </tr>
<%
    for (java.util.Map<String, Object> sale : sales) {
%>
        <tr>
            <td><%= sale.get("auction_id") %></td>
            <td><%= sale.get("item_title") %></td>
            <td><%= sale.get("category") %></td>
            <td><%= sale.get("brand") %></td>
            <td><%= sale.get("seller") %></td>
            <td><%= sale.get("winner") != null ? sale.get("winner") : "N/A" %></td>
            <td>$<%
                Object priceObj = sale.get("final_price");
                if (priceObj != null) {
                    out.print(String.format("%.2f", ((Number)priceObj).doubleValue()));
                } else {
                    out.print("0.00");
                }
            %></td>
            <td><%= sale.get("closing_date") %></td>
        </tr>
<%
    }
    
    if (sales.isEmpty()) {
%>
        <tr>
            <td colspan="8">No sales data available.</td>
        </tr>
<%
    }
%>
    </table>
</div>

<!-- 3. EARNINGS PER ITEM TYPE -->
<div class="section">
    <h2>3. Earnings Per Item Type (Category)</h2>
    <table>
        <tr>
            <th>Category</th>
            <th>Total Earnings</th>
            <th>Number of Items Sold</th>
            <th>Average Price</th>
        </tr>
<%
    // Group by category
    java.util.Map<String, java.util.List<java.util.Map<String, Object>>> byCategory = new java.util.HashMap<>();
    for (java.util.Map<String, Object> sale : sales) {
        String category = (String) sale.get("category");
        if (!byCategory.containsKey(category)) {
            byCategory.put(category, new java.util.ArrayList<>());
        }
        byCategory.get(category).add(sale);
    }
    
    for (java.util.Map.Entry<String, java.util.List<java.util.Map<String, Object>>> entry : byCategory.entrySet()) {
        String category = entry.getKey();
        java.util.List<java.util.Map<String, Object>> categorySales = entry.getValue();
        
        double categoryTotal = 0;
        for (java.util.Map<String, Object> sale : categorySales) {
            Object priceObj = sale.get("final_price");
            if (priceObj != null) {
                categoryTotal += ((Number)priceObj).doubleValue();
            }
        }
        double avgPrice = categorySales.size() > 0 ? categoryTotal / categorySales.size() : 0;
%>
        <tr>
            <td><%= category %></td>
            <td>$<%= String.format("%.2f", categoryTotal) %></td>
            <td><%= categorySales.size() %></td>
            <td>$<%= String.format("%.2f", avgPrice) %></td>
        </tr>
<%
    }
    
    if (byCategory.isEmpty()) {
%>
        <tr>
            <td colspan="4">No sales data by category available.</td>
        </tr>
<%
    }
%>
    </table>
</div>

<!-- 4. EARNINGS PER END-USER (SELLER) -->
<div class="section">
    <h2>4. Earnings Per End-User (Seller)</h2>
    <table>
        <tr>
            <th>Seller Username</th>
            <th>Total Earnings</th>
            <th>Number of Items Sold</th>
            <th>Average Price</th>
        </tr>
<%
    // Group by seller
    java.util.Map<String, java.util.List<java.util.Map<String, Object>>> bySeller = new java.util.HashMap<>();
    for (java.util.Map<String, Object> sale : sales) {
        String seller = (String) sale.get("seller");
        if (!bySeller.containsKey(seller)) {
            bySeller.put(seller, new java.util.ArrayList<>());
        }
        bySeller.get(seller).add(sale);
    }
    
    for (java.util.Map.Entry<String, java.util.List<java.util.Map<String, Object>>> entry : bySeller.entrySet()) {
        String seller = entry.getKey();
        java.util.List<java.util.Map<String, Object>> sellerSales = entry.getValue();
        
        double sellerTotal = 0;
        for (java.util.Map<String, Object> sale : sellerSales) {
            Object priceObj = sale.get("final_price");
            if (priceObj != null) {
                sellerTotal += ((Number)priceObj).doubleValue();
            }
        }
        double avgPrice = sellerSales.size() > 0 ? sellerTotal / sellerSales.size() : 0;
%>
        <tr>
            <td><%= seller %></td>
            <td>$<%= String.format("%.2f", sellerTotal) %></td>
            <td><%= sellerSales.size() %></td>
            <td>$<%= String.format("%.2f", avgPrice) %></td>
        </tr>
<%
    }
    
    if (bySeller.isEmpty()) {
%>
        <tr>
            <td colspan="4">No sales data by seller available.</td>
        </tr>
<%
    }
%>
    </table>
</div>

<!-- 5. BEST-SELLING ITEMS -->
<div class="section">
    <h2>5. Best-Selling Items</h2>
    <p>Sorted by highest final sale price</p>
    <table>
        <tr>
            <th>Rank</th>
            <th>Auction ID</th>
            <th>Item Title</th>
            <th>Category</th>
            <th>Brand</th>
            <th>Seller</th>
            <th>Final Price</th>
        </tr>
<%

    java.util.Collections.sort(sales, new java.util.Comparator<java.util.Map<String, Object>>() {
        public int compare(java.util.Map<String, Object> a, java.util.Map<String, Object> b) {
            Object priceAObj = a.get("final_price");
            Object priceBObj = b.get("final_price");
            long priceA = priceAObj != null ? ((Number)priceAObj).longValue() : 0;
            long priceB = priceBObj != null ? ((Number)priceBObj).longValue() : 0;
            return Long.compare(priceB, priceA); // Descending order
        }
    });
    
    int rank = 1;
    for (java.util.Map<String, Object> sale : sales) {
        if (rank > 10) break; // Show top 10
%>
        <tr>
            <td><%= rank++ %></td>
            <td><%= sale.get("auction_id") %></td>
            <td><%= sale.get("item_title") %></td>
            <td><%= sale.get("category") %></td>
            <td><%= sale.get("brand") %></td>
            <td><%= sale.get("seller") %></td>
            <td>$<%
                Object priceObj2 = sale.get("final_price");
                if (priceObj2 != null) {
                    out.print(String.format("%.2f", ((Number)priceObj2).doubleValue()));
                } else {
                    out.print("0.00");
                }
            %></td>
        </tr>
<%
    }
    
    if (sales.isEmpty()) {
%>
        <tr>
            <td colspan="7">No sales data available.</td>
        </tr>
<%
    }
%>
    </table>
</div>

<!-- 6. BEST BUYERS -->
<div class="section">
    <h2>6. Best Buyers</h2>
    <p>Users who have spent the most money (Top Buyers)</p>
    <table>
        <tr>
            <th>Rank</th>
            <th>Buyer Username</th>
            <th>Total Spent</th>
            <th>Number of Items Purchased</th>
            <th>Average Purchase Price</th>
        </tr>
<%
    // Group by buyer (winner)
    java.util.Map<String, java.util.List<java.util.Map<String, Object>>> byBuyer = new java.util.HashMap<>();
    for (java.util.Map<String, Object> sale : sales) {
        String winner = (String) sale.get("winner");
        if (winner != null) {
            if (!byBuyer.containsKey(winner)) {
                byBuyer.put(winner, new java.util.ArrayList<>());
            }
            byBuyer.get(winner).add(sale);
        }
    }
    
    // Create list of buyers with totals
    java.util.List<java.util.Map<String, Object>> buyerStats = new java.util.ArrayList<>();
    for (java.util.Map.Entry<String, java.util.List<java.util.Map<String, Object>>> entry : byBuyer.entrySet()) {
        String buyer = entry.getKey();
        java.util.List<java.util.Map<String, Object>> buyerPurchases = entry.getValue();
        
        double buyerTotal = 0;
        for (java.util.Map<String, Object> sale : buyerPurchases) {
            Object priceObj = sale.get("final_price");
            if (priceObj != null) {
                buyerTotal += ((Number)priceObj).doubleValue();
            }
        }
        
        java.util.Map<String, Object> stat = new java.util.HashMap<>();
        stat.put("buyer", buyer);
        stat.put("total", buyerTotal);
        stat.put("count", buyerPurchases.size());
        stat.put("average", buyerPurchases.size() > 0 ? buyerTotal / buyerPurchases.size() : 0);
        buyerStats.add(stat);
    }
    
    // Sort by total spent (descending)
    java.util.Collections.sort(buyerStats, new java.util.Comparator<java.util.Map<String, Object>>() {
        public int compare(java.util.Map<String, Object> a, java.util.Map<String, Object> b) {
            Double totalA = (Double) a.get("total");
            Double totalB = (Double) b.get("total");
            return totalB.compareTo(totalA); // Descending order
        }
    });
    
    rank = 1;
    for (java.util.Map<String, Object> stat : buyerStats) {
        if (rank > 10) break; // Show top 10
%>
        <tr>
            <td><%= rank++ %></td>
            <td><%= stat.get("buyer") %></td>
            <td>$<%= String.format("%.2f", (Double) stat.get("total")) %></td>
            <td><%= stat.get("count") %></td>
            <td>$<%= String.format("%.2f", (Double) stat.get("average")) %></td>
        </tr>
<%
    }
    
    if (buyerStats.isEmpty()) {
%>
        <tr>
            <td colspan="5">No buyer data available.</td>
        </tr>
<%
    }
%>
    </table>
</div>

<%
    db.closeConnection(con);
    
} catch (Exception e) {
    out.println("<div style='padding: 20px; background-color: #ffebee; border: 2px solid #f44336; border-radius: 5px; margin: 20px;'>");
    out.println("<h3 style='color: #d32f2f;'>Error generating reports</h3>");
    out.println("<p style='color: #c62828;'><strong>Error:</strong> " + e.getMessage() + "</p>");
    out.println("<details><summary>Technical Details</summary><pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    out.println("</pre></details>");
    out.println("</div>");
}
%>

</body>
</html>
