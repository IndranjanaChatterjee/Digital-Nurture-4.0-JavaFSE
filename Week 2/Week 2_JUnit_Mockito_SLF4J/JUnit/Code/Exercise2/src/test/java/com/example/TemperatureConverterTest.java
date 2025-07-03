package com.example;

import org.junit.Test;
import static org.junit.Assert.*;

public class TemperatureConverterTest {

    TemperatureConverter converter = new TemperatureConverter();

    @Test
    public void testToFahrenheit() {
        double result = converter.toFahrenheit(0);
        assertEquals(32.0, result, 0.001);
    }

    @Test
    public void testToCelsius() {
        double result = converter.toCelsius(212);
        assertEquals(100.0, result, 0.001);
    }
}
