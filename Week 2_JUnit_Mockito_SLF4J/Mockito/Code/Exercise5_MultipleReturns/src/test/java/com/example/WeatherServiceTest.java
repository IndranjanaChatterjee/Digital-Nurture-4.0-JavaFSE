package com.example;

import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

public class WeatherServiceTest {

    @Test
    public void testMultipleForecasts() {

        WeatherApi mockApi = mock(WeatherApi.class);

        when(mockApi.getForecast())
                .thenReturn("Sunny")
                .thenReturn("Cloudy")
                .thenReturn("Rainy");

        WeatherService service = new WeatherService(mockApi);
        String[] result = service.fetchForecasts();

        //Verify the results
        assertArrayEquals(new String[] { "Sunny", "Cloudy", "Rainy" }, result);
    }
}
