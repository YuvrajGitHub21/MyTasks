package com.mytasks.adapters.in.http.error;

import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/** Converts API exceptions into the shared error envelope defined in the LLD. */
@RestControllerAdvice
public class ApiExceptionHandler {

	private static final Logger logger = LoggerFactory.getLogger(ApiExceptionHandler.class);

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ApiErrorResponse> handleValidation(
			MethodArgumentNotValidException exception,
			HttpServletRequest request
	) {
		Map<String, String> fieldErrors = new LinkedHashMap<>();
		exception.getBindingResult().getFieldErrors().forEach(fieldError -> {
			String validationCode = fieldError.getCode();
			String stableCode = validationCode == null
					? "INVALID"
					: validationCode.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase(Locale.ROOT);
			fieldErrors.putIfAbsent(fieldError.getField(), stableCode);
		});

		return ResponseEntity.badRequest().body(error(
				"VALIDATION_ERROR",
				"Request validation failed.",
				fieldErrors,
				request
		));
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<ApiErrorResponse> handleUnexpected(
			Exception exception,
			HttpServletRequest request
	) {
		String requestId = requestId(request);
		logger.error("Unhandled API exception. requestId={}", requestId, exception);
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error(
				"INTERNAL_ERROR",
				"An unexpected error occurred.",
				Map.of(),
				requestId
		));
	}

	private ApiErrorResponse error(
			String code,
			String message,
			Map<String, String> fieldErrors,
			HttpServletRequest request
	) {
		return error(code, message, fieldErrors, requestId(request));
	}

	private ApiErrorResponse error(
			String code,
			String message,
			Map<String, String> fieldErrors,
			String requestId
	) {
		return new ApiErrorResponse(new ApiErrorResponse.ErrorDetail(code, message, fieldErrors, requestId));
	}

	private String requestId(HttpServletRequest request) {
		Object value = request.getAttribute(RequestIdFilter.REQUEST_ID_ATTRIBUTE);
		return value instanceof String requestId ? requestId : "unknown";
	}
}
