<%@ page import="org.apache.http.Header"%>
<%@ page import="org.apache.http.HttpEntity"%>
<%@ page import="org.apache.http.client.ResponseHandler"%>
<%@ page import="org.apache.http.client.methods.CloseableHttpResponse"%>
<%@ page import="org.apache.http.client.methods.HttpPost"%>
<%@ page import="org.apache.http.client.methods.HttpGet" %>
<%@ page import="org.apache.http.client.methods.RequestBuilder"%>
<%@ page import="org.apache.http.entity.ContentType"%>
<%@ page import="org.apache.http.entity.StringEntity"%>
<%@ page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@ page import="org.apache.http.impl.client.HttpClients"%>
<%@ page import="org.apache.http.message.BasicHeader"%>
<%@ page import="org.apache.http.util.EntityUtils"%>
<%@ page import="org.apache.commons.codec.binary.Base64"%>
<%@ page import="com.fasterxml.jackson.databind.JsonNode"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@ page import="com.google.gson.JsonArray"%>
<%@ page import="com.google.gson.JsonElement"%>
<%@ page import="com.google.gson.JsonObject"%>
<%@ page import="com.google.gson.JsonParser"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Arrays"%>
<%@ page import="java.util.List"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%
	String code = (String)request.getParameter("code");
	String scope = (String)request.getParameter("scope");
	String session_state = (String)request.getParameter("session_state");
	String prompt = (String)request.getParameter("prompt");
	%>
	
	<%
	String client_id = "647784098084-6t1bqntkr7m2csq9dbrog1hv5h56b4hd.apps.googleusercontent.com";
	String client_secret = "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";
	CloseableHttpClient httpClient = HttpClients.createDefault();
	HttpPost httpPost = new HttpPost("https://www.googleapis.com/oauth2/v4/token");
	httpPost.setHeader("content-type", "application/x-www-form-urlencoded");
	String request_body = "grant_type=authorization_code&" +
						"code=" + code +
						"&client_id=647784098084-6t1bqntkr7m2csq9dbrog1hv5h56b4hd.apps.googleusercontent.com" +
						"&client_secret=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" +
						"&redirect_uri=http://localhost:8080/20205203/session.jsp";
	StringEntity entity = new StringEntity(request_body);
	httpPost.setEntity(entity);
	
	CloseableHttpResponse resp = httpClient.execute(httpPost);
	String return_body = EntityUtils.toString(resp.getEntity());
	JsonParser parser = new JsonParser();
	JsonElement jsonTree = parser.parse(return_body);
	String access_token = jsonTree.getAsJsonObject().get("access_token").toString();
	String expires_in = jsonTree.getAsJsonObject().get("expires_in").toString();
	String scope2 = jsonTree.getAsJsonObject().get("scope").toString();
	String token_type = jsonTree.getAsJsonObject().get("token_type").toString();
	String id_token = jsonTree.getAsJsonObject().get("id_token").toString();
	%>				
	<%
			Base64 base64Url = new Base64(true);
			String[] split_string = id_token.split("\\.");
			String header = new String(base64Url.decode(split_string[0]));
			String body = new String(base64Url.decode(split_string[1]));
			String signature = new String(base64Url.decode(split_string[2]));
	%>
	<%
	jsonTree = parser.parse(body);
	String email = jsonTree.getAsJsonObject().get("email").toString();
	email = email.replace("\"","");
	%>
	<a href="sendmail.jsp">Gửi email</a>
	<%
	CloseableHttpClient httpClient2 = HttpClients.createDefault();
	String api_Url = "https://www.googleapis.com/gmail/v1/users/" +email+ "/messages";

	HttpGet listMails = new HttpGet(api_Url);
	listMails.setHeader("Authorization","Bearer " + access_token);
	CloseableHttpResponse resp2 = httpClient.execute(listMails);
	return_body = EntityUtils.toString(resp2.getEntity());
	
	JsonElement mails = new JsonParser().parse(return_body);
	JsonObject obj = mails.getAsJsonObject();
	JsonArray messages = obj.getAsJsonArray("messages");
	JsonArray mes = new JsonArray();
	int n = messages.size();
	%>
	<table>
		<tr>
		<td>Subject</td>
		<td>From</td>
		<td>Date</td>
		</tr>
	<%
	for (int i=0;i<n;i++){
		JsonObject message = messages.get(i).getAsJsonObject();
		String threadId = message.get("threadId").getAsString();
		HttpGet mail2 = new HttpGet(api_Url+"/"+threadId);
		mail2.setHeader("Authorization","Bearer " + access_token);
		CloseableHttpResponse resp3 = httpClient.execute(mail2);
		return_body = EntityUtils.toString(resp3.getEntity());
		JsonElement mail = new JsonParser().parse(return_body);
		obj = mail.getAsJsonObject();
		JsonObject payload = obj.get("payload").getAsJsonObject();
		JsonArray headers = payload.getAsJsonArray("headers");
		String subject = new String();
		String from = new String();
		String date = new String();
		for(int j=0;j<headers.size();j++){
			JsonObject hd = headers.get(j).getAsJsonObject();
			String name = hd.get("name").getAsString();
			if(name.equals("Subject")){
				subject = hd.get("value").getAsString();
			} else if (name.equals("From")){
				from = hd.get("value").getAsString();
			} else if (name.equals("Date")){
				date = hd.get("value").getAsString();
			}
		}
		%>
		<tr>
		<td><%=subject %></td>
		<td><%=from %></td>
		<td><%=date %></td>
		</tr>
		
	<%}%>
	</table>
	<p><%=mes %></p>
	
	<a href="work.jsp">Continue working with Google account: <%= email%></a>
	
	<%
	Cookie cookie = new Cookie("session_id",email);
	cookie.setMaxAge(60*60*24);
	response.addCookie(cookie);
	%>
</body>
</html>