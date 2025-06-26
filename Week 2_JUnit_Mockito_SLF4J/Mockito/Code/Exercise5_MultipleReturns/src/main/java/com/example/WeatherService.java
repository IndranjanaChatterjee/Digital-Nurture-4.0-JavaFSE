package com.example;

public class WeatherService {

    private final WeatherApi api;

    public WeatherService(WeatherApi api) {
        this.api = api;
    }

    public String[] fetchForecasts() {
        return new String[] {
                api.getForecast(),
                api.getForecast(),
                api.getForecast()
        };
    }
}
