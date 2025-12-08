<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert Auction</title>
</head>
<body>
<%@ page import="java.sql.*" %>

<%
String itemTitle = request.getParameter("item_title");
String itemDescription = request.getParameter("item_description");
String category = request.getParameter("category");
String brand = request.getParameter("brand");
String color = request.getParameter("color");
String size = request.getParameter("size");
String condition = request.getParameter("clothing_condition");

String startPrice = request.getParameter("start_price");
String bidIncrement = request.getParameter("bid_increment");
String hiddenMinPrice = request.getParameter("hidden_min_price");

String closingDate = request.getParameter("closing_date");
String closingTime = request.getParameter("closing_time");

try {
/* 	int startPrice = Integer.parseInt(startPriceString);
	int bidIncrement = Integer.parseInt(bidIncrementString);
	int hiddenMinPrice = Integer.parseInt(hiddenMinPriceString); */
	
	String closingDateTime = closingDate + " " + closingTime + ":00";
	
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
    Statement st = con.createStatement();
    
    String query = "INSERT INTO auction (seller, start_price, bid_increment, hidden_min_price, closing_date, item_title, " + 
    		"item_description, category, brand, clothing_condition, color, size) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	PreparedStatement ps = con.prepareStatement(query);
	String seller = "" + session.getAttribute("user");
	ps.setString(1, seller);
	ps.setString(2, startPrice);
	ps.setString(3, bidIncrement);
	ps.setString(4, hiddenMinPrice);
	ps.setString(5, closingDateTime);
	ps.setString(6, itemTitle);
	ps.setString(7, itemDescription);
	ps.setString(8, category);
	ps.setString(9, brand);
	ps.setString(10, condition);
	ps.setString(11, color);
	ps.setString(12, size);
	
	ps.executeUpdate();


%>

<p>Auction successfully created.</p>
<p>Redirecting to home page.</p>

<% 

      response.setHeader("Refresh", "5; URL=success.jsp");
} catch (Exception e) {
	out.println(e);
}

%>

</body>
</html>