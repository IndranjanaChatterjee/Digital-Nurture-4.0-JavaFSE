package com.example;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ParameterizedLoggingExample {
    private static final Logger logger = LoggerFactory.getLogger(ParameterizedLoggingExample.class);

    public static void main(String[] args) {
        String user = "Indranjana";
        int age = 21;

        logger.info("User {} has logged in", user);
        logger.debug("User {} is {} years old", user, age);
    }
}
