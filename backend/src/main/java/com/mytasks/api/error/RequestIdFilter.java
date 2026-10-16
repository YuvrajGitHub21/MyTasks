package com.mytasks.api.error;

import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/** Assigns a safe correlation ID so a client report can be matched to server logs. */
@Component
public class RequestIdFilter extends OncePerRequestFilter {

	public static final String HEADER_NAME = "X-Request-ID";
	public static final String REQUEST_ID_ATTRIBUTE = RequestIdFilter.class.getName() + ".requestId";

	@Override
	protected void doFilterInternal(
			HttpServletRequest request,
			HttpServletResponse response,
			FilterChain filterChain
	) throws ServletException, IOException {
		String requestId = validUuid(request.getHeader(HEADER_NAME));
		if (requestId == null) {
			requestId = UUID.randomUUID().toString();
		}

		request.setAttribute(REQUEST_ID_ATTRIBUTE, requestId);
		response.setHeader(HEADER_NAME, requestId);
		filterChain.doFilter(request, response);
	}

	private String validUuid(String candidate) {
		if (candidate == null) {
			return null;
		}
		try {
			UUID parsed = UUID.fromString(candidate);
			return parsed.toString().equalsIgnoreCase(candidate) ? parsed.toString() : null;
		} catch (IllegalArgumentException exception) {
			return null;
		}
	}
}
