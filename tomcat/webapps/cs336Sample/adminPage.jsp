<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Page</title>
</head>
<body>

<h1>Welcome Admin!</h1>

<form action="createCustomerRep.jsp" method="GET">
    <button type="submit">Create Customer Rep Account</button>
</form>
<br>
<form action="salesReports.jsp" method="GET">
    <button type="submit">Generate Sales Reports</button>
</form>

<br><br>

<form action="logout.jsp" method="POST">
    <button type="submit">Log Out</button>
</form>

</body>
</html>