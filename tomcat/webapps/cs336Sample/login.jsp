<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login Form</title>
</head>
<body>
<h1>Welcome to BuyMe!</h1>

	<form action="checkLoginDetails.jsp" method="POST">
		Username: <input type="text" name="username"/> <br/>
		Password:<input type="password" name="password"/> <br/>
		<input type="submit" value="Submit"/>
	</form>
	
	<br>
	
<form action="createAccount.jsp" method="POST">
    <button type="submit">Create an account</button>
</form>

</body>
</html>