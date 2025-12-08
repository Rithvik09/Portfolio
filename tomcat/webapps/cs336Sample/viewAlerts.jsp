<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Alerts</title>
<style>
    .alert { padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; }
    .unread { background-color: #fff3cd; font-weight: bold; }
    .read { background-color: #f8f9fa; }
</style>
</head>
<body>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<a href='success.jsp'>[Return to Home Page]</a> <br> <br>

<h2>My Alerts</h2>

<%
String currentUser = "" + session.getAttribute("user");

try {
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();
	
	String getSavedAlerts = "SELECT category, brand, color, size FROM alert_for_item WHERE username=?";
	PreparedStatement psSaved = con.prepareStatement(getSavedAlerts);
	psSaved.setString(1, currentUser);
	ResultSet rsSaved = psSaved.executeQuery();
	
	while(rsSaved.next()){
		String category = rsSaved.getString("category");
		String brand = rsSaved.getString("brand");
		String color = rsSaved.getString("color");
		String size = rsSaved.getString("size");
		
		String findAuctions = "SELECT auction_id, item_title FROM auction WHERE auction_status ='active' " +
		"AND category = ? AND brand = ? AND color = ? and size = ?";
		
		PreparedStatement psAuction = con.prepareStatement(findAuctions);
		psAuction.setString(1, category);
		psAuction.setString(2, brand);
		psAuction.setString(3, color);
		psAuction.setString(4, size);
		
		ResultSet rsAuction = psAuction.executeQuery();
		
		while (rsAuction.next()){
			int auctionId = rsAuction.getInt("auction_id");
			String itemTitle = rsAuction.getString("item_title");
			
			String message = "New auction #" + auctionId + " for " + itemTitle + " (" + brand + ", " + color + ", " + size + ")";
			
			String messageCheck = "SELECT 1 FROM alerts WHERE username = ? AND message = ?";
			PreparedStatement psCheck = con.prepareStatement(messageCheck);
			psCheck.setString(1, currentUser);
			psCheck.setString(2, message);
			ResultSet rsCheck = psCheck.executeQuery();
			
			if (!rsCheck.next()){
				String insert = "INSERT INTO alerts (username, message) VALUES (?,?)";
				PreparedStatement psInsert = con.prepareStatement(insert);
				psInsert.setString(1, currentUser);
				psInsert.setString(2, message);
				psInsert.executeUpdate();
			}
		}
	}
	
	
	
	String markRead = request.getParameter("mark_read");
	if (markRead != null) {
		int alertId = Integer.parseInt(markRead);
		String updateAlert = "UPDATE alerts SET is_read = true WHERE alert_id = ? AND username = ?;";
		PreparedStatement psUpdate = con.prepareStatement(updateAlert);
		psUpdate.setInt(1, alertId);
		psUpdate.setString(2, currentUser);
		psUpdate.executeUpdate();
	}
	
	String getAlerts = "SELECT alert_id, message, is_read, created_at FROM alerts " +
			"WHERE username = ? ORDER BY created_at DESC;";
	PreparedStatement ps = con.prepareStatement(getAlerts);
	ps.setString(1, currentUser);
	ResultSet rs = ps.executeQuery();
	
	boolean hasAlerts = false;
	
	while (rs.next()) {
		hasAlerts = true;
		int alertId = rs.getInt("alert_id");
		String message = rs.getString("message");
		boolean isRead = rs.getBoolean("is_read");
		Timestamp createdAt = rs.getTimestamp("created_at");
		
		String alertClass = isRead ? "alert read" : "alert unread";
%>

<div class="<%=alertClass%>">
	<p><strong><%=createdAt%></strong></p>
	<p><%=message%></p>
	<% if (!isRead) { %>
		<a href="viewAlerts.jsp?mark_read=<%=alertId%>">[Mark as Read]</a>
	<% } %>
</div>

<%
	}
	
	if (!hasAlerts) {
		out.println("<p>No alerts.</p>");
	}
	
	db.closeConnection(con);
	
} catch (Exception e) {
	out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
