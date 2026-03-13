package com.example.oltp;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.observation.ObservationRegistry;
import io.micrometer.observation.aop.ObservedAspect;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ObservationConfig {

    @Bean
    public ObservedAspect observedAspect(ObservationRegistry observationRegistry) {
        return new ObservedAspect(observationRegistry);
    }

    @Bean
    public ObservationRegistry observationRegistry(MeterRegistry meterRegistry) {
        ObservationRegistry observationRegistry = ObservationRegistry.create();
        
        // Connect observations to metrics
        observationRegistry.observationConfig()
            .observationHandler(
                // Convert observations to metrics
                new io.micrometer.observation.DefaultMeterObservationHandler(meterRegistry)
            );
        
        return observationRegistry;
    }
}