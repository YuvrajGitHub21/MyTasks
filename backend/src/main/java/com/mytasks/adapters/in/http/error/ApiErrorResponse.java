package com.mytasks.adapters.in.http.error;

import java.util.Map;

/** The stable error envelope returned by business API endpoints. */
public record ApiErrorResponse(ErrorDetail error) {

	public record ErrorDetail(
			String code,
			String message,
			Map<String, String> fieldErrors,
			String requestId
	) {
	}
}
