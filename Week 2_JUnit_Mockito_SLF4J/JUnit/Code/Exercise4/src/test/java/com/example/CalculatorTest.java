package com.example;

import org.junit.Before;
import org.junit.After;
import org.junit.Test;
import static org.junit.Assert.*;

public class CalculatorTest {

    private Calculator calculator;

    // Arrange setup method
    @Before
    public void setUp() {
        calculator = new Calculator();
        System.out.println("Before test Calculator initialized");
    }

    // Actual test method
    @Test
    public void testAddition() {

        // Act
        int result = calculator.add(2, 3);

        // Assert
        assertEquals(5, result);
    }

    // Teardown cleanup method
    @After
    public void tearDown() {
        calculator = null;
        System.out.println("After test Calculator cleaned up");
    }
}
