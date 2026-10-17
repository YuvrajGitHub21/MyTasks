package com.mytasks.bootstrap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.servers.Server;

@SpringBootApplication(scanBasePackages = "com.mytasks")
@OpenAPIDefinition(
		info = @Info(
				title = "MyTasks API",
				version = "v1",
				description = "Versioned API contract for the MyTasks application."
		),
		servers = @Server(url = "/v1", description = "Versioned business API")
)
public class MyTasksApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(MyTasksApiApplication.class, args);
	}

}
