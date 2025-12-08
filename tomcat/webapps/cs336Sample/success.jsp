<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Success Page</title>
</head>
<body>

<a href='logout.jsp'>[Log out]</a> <br> <br>

    <%
        if ((session.getAttribute("user") == null)) {
    %>
        You are not logged in<br/>
        <a href="login.jsp">Please Login</a>
    <%
        } else {
    %>
        Welcome <%= session.getAttribute("user") %>!
        <!-- this will display the username that is stored in the session. -->
        
    <%
        }
    %>
    
   <br> <br>
   <a href='faqs.jsp'>[FAQs]</a> 
   <br>
   <a href='createAuction.jsp'>[Create an Auction]</a> 
   <br>
   <a href='viewMyAuctions.jsp'>[View My Auctions (As Seller)]</a> 
   <br>
   <a href='viewBuyerHistory.jsp'>[View My Bidding History (As Buyer)]</a>
   <br>
   <a href='viewAllAuctions.jsp'>[View All Auctions and Bid]</a> 
   <br>
   <a href='searchAuctions.jsp'>[Advanced Search]</a>
   <br>
   <a href='setItemAlerts.jsp'>[Set an Alert for Items]</a>
   <br>
   <a href='viewAlerts.jsp'>[View My Alerts]</a>
    
    
</body>
</html>
