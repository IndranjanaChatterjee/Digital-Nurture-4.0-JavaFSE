package com.cognizant.spring;

import com.cognizant.spring.entity.Country;
import com.cognizant.spring.service.CountryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application implements CommandLineRunner {

	@Autowired
	private CountryService countryService;

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}

	@Override
	public void run(String... args) throws Exception {

		// Find by code
		Country country = countryService.findCountryByCode("IN");
		System.out.println("Country with code IN: " + country);

		// Add new country
		Country newCountry = new Country();
		newCountry.setCoCode("SDK");
		newCountry.setCoName("JAVA_Land");
		countryService.addCountry(newCountry);
		System.out.println("Added Country: " + countryService.findCountryByCode("SDK"));

		// Update existing country
		countryService.updateCountry("SDK", "ADVANCE_JAVA_Land");
		System.out.println("After update: " + countryService.findCountryByCode("SDK"));

		// Delete a country
		countryService.deleteCountry("SDK");
		System.out.println("Deleted country with code SDK");
	}
}
