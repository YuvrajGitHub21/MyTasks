package com.mytasks.worker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

/** Separate process entry point for asynchronous jobs; business jobs are added in later milestones. */
@SpringBootApplication(scanBasePackages = "com.mytasks")
public class MyTasksWorkerApplication {
    public static void main(String[] args) {
        new SpringApplicationBuilder(MyTasksWorkerApplication.class)
                .web(WebApplicationType.NONE)
                .run(args);
    }
}
