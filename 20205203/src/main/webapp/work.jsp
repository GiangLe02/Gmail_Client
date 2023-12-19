<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html><head><title>Google OAuth: Working in session</title></head>
<body>
	<%
	Cookie[] cookies = request.getCookies();
	String logout = (String)request.getParameter("logout");
	if (logout != null) {
	for (int i=0; i<cookies.length; i++) {
	if (cookies[i].getName().compareTo("session_id") == 0) {
	cookies[i].setMaxAge(0);
	response.addCookie(cookies[i]);
	response.sendRedirect("login.jsp");
	return;
	}
	}
	}
	boolean session_validate = false;
	for (int i=0; i<cookies.length; i++) {
	if (cookies[i].getName().compareTo("session_id") == 0) {
	session_validate = true;
	%>
	<h3>You are working in a session identified by following cookie:</h3>
	<%= cookies[i].getName() %>: <%= cookies[i].getValue() %>
	<p>
	<a href="work.jsp?logout=yes">Logout</a>
	<%
	}
	}
	if (!session_validate) {
	%>
	<h3>Your session has terminated</h3>
	Please <a href="login.jsp">login</a> again.
	<%
	}
	%>
</body>
</html>