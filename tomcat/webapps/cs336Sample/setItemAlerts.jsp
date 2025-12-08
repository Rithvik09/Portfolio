<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Set Item Alerts</title>
</head>
<body>
<%@ page import="java.sql.*" %>


<a href='success.jsp'>[Return to Home Page]</a>


<h1>Set an Alert for Items</h1>

<form id="createItemAlertForm" action="createItemAlert.jsp" method="POST">


	Category:<br> 
	<label><input type="radio" name="category" value="shirt" checked>Shirt</label><br>
	<label><input type="radio" name="category" value="pants">Pants</label><br>
	<label><input type="radio" name="category" value="hoodie">Hoodie</label><br><br> 
	
	Brand: <input type ="text" name="brand"><br><br> 
	Color: <input type ="text" name="color"><br><br> 
	
	Size: <br> 
	<label><input type="radio" name="size" value="XS" checked>XS</label><br>
	<label><input type="radio" name="size" value="S">S</label><br>
	<label><input type="radio" name="size" value="M">M</label><br> 
	<label><input type="radio" name="size" value="L">L</label><br>
	<label><input type="radio" name="size" value="XL">XL</label><br><br> 
	<button type="submit">Set Alert</button>
	
	<p id="errorMessage" style = "color:red;"></p>
	
</form>

<script>
	
document.getElementById("createItemAlertForm").addEventListener("submit", function(event){
		
	const form = event.target;
	const error = document.getElementById("errorMessage");
	error.textContent = "";
	
	
	const category = form.elements["category"].value;
	const brand = form.elements["brand"].value.trim();
	const color = form.elements["color"].value.trim();
	const size = form.elements["size"].value;
	
		
	if (category === "" || brand === "" || color === "" || size === "") {
		error.textContent = "Error: Please fill in all required fields.";
		event.preventDefault();
	}
	
	
		
});
	
</script>

<u>Current Alerts:</u> 
<br> 

<% 

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme", "root", "christian123");
Statement st = con.createStatement();

String user = "" + session.getAttribute("user");

String str = "SELECT category, brand, color, size FROM alert_for_item WHERE username = ?";
PreparedStatement ps = con.prepareStatement(str);
ps.setString(1, user);
ResultSet result = ps.executeQuery();

while (result.next()) {
	
	String category = result.getString("category");
	String brand = result.getString("brand");
	String color = result.getString("color");
	String size = result.getString("size");

 %>

<%=category%> - <%=brand%>, <%=color%>, <%=size%> 
<form action="deleteItemAlert.jsp" method="POST" style="display:inline;"> 
	<input type="hidden" name ="category" value="<%=category%>">
	<input type="hidden" name ="brand" value="<%=brand%>">
	<input type="hidden" name ="color" value="<%=color%>">
	<input type="hidden" name ="size" value="<%=size%>">
	<button type="submit">Remove</button>
</form>

<br>

<% } %>

</body>
</html>