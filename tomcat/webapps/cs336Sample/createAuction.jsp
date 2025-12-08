<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Create an Auction</title>
</head>
<body>

<%@ page import="java.sql.*" %>

<a href='success.jsp'>[Return to Home Page]</a>


<h1>Create an Auction</h1>

<form id="createAuctionForm" action="insertAuction.jsp" method="POST">


	Item title: 
	<input type ="text" name="item_title"><br><br>
	
	Description:
	<input type ="text" name="item_description"><br><br>
	
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
	
	Condition:<br> 
	<label><input type="radio" name="clothing_condition" value="new" checked>New</label><br>
	<label><input type="radio" name="clothing_condition" value="used">Used</label><br>
	<label><input type="radio" name="clothing_condition" value="fair">Fair</label><br><br> 
	
	Starting price: <input type="number" name="start_price"><br><br> 
	Bid Increment: <input type="number" name="bid_increment"><br><br> 
	Hidden Minimum Price: <input type="number" name="hidden_min_price"><br><br> 
	
	Closing Date: <input type="date" name="closing_date">
	Closing time: <input type="time" name="closing_time"><br><br>
	
	<button type="submit">Create Auction</button>
	
	<p id="errorMessage" style = "color:red;"></p>
	
</form>

<script>
	
document.getElementById("createAuctionForm").addEventListener("submit", function(event){
		
	const form = event.target;
	const error = document.getElementById("errorMessage");
	error.textContent = "";
	
	const item_title = form.elements["item_title"].value.trim();
	const item_description = form.elements["item_description"].value.trim();
	const category = form.elements["category"].value;
	const brand = form.elements["brand"].value.trim();
	const color = form.elements["color"].value.trim();
	const size = form.elements["size"].value;
	const clothing_condition = form.elements["clothing_condition"].value;
	const start_price = form.elements["start_price"].value.trim();
	const bid_increment = form.elements["bid_increment"].value.trim();
	const hidden_min_price = form.elements["hidden_min_price"].value.trim();
	const closing_date = form.elements["closing_date"].value.trim();
	const closing_time = form.elements["closing_time"].value.trim();
		
	if (item_title === "" || item_description === "" || category === "" || brand === "" || 
			color === "" || size === "" || clothing_condition === "" || start_price === "" || 
				bid_increment === "" || hidden_min_price === "" || closing_date === "" || 
					closing_time === "") {
		error.textContent = "Error: Please fill in all required fields.";
		event.preventDefault();
	}
		
});
	
</script>

</body>
</html>