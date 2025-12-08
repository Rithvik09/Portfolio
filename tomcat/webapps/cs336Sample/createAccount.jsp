<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Create Account</title>
</head>
<body>

<h2>Create Account</h2>

<form action="insertUser.jsp" method="POST">
    Username: <input type="text" name="username" required><br/>
    Password: <input type="password" name="password" required><br/>
    <input type="submit" value="Create Account">
</form>

<br>

<form action="login.jsp" method="POST">
    <button type="submit">Back to Login</button>
</form>

</body>
</html>