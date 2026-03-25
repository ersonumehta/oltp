package com.example.oltp;

import io.micrometer.observation.annotation.Observed;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    private static final Logger log = LoggerFactory.getLogger(HomeController.class);

    @GetMapping("/")
    @Observed(name = "custom2.operation2",contextualName = "customOperation2")
    public String home() {
        log.info("Home endpoint called");
        return "Hello World!";
    }

    @GetMapping("/greet/{name}")
    @Observed(name = "greet.operation", contextualName = "greetOperation")
    public String greet(@PathVariable String name) {
        log.info("Greeting user[updated]: {}", name);
        simulateWork();
        return "Hello, [updated]" + name + "!";
    }

    @GetMapping("/slow")
    @Observed(name = "slow.operation", contextualName = "slowOperation")
    public String slow() throws InterruptedException {
        log.info("Starting slow operation");
        Thread.sleep(500);
        log.info("Slow operation completed");
        return "Done!";
    }

    @Observed(name = "custom.operation", contextualName = "customOperation")
    private void simulateWork() {
        try {
            Thread.sleep(50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}