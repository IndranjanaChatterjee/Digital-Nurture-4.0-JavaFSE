package com.cognizant.ormlearn;

import com.cognizant.ormlearn.entity.Country;
import com.cognizant.ormlearn.repository.CountryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.List;

@SpringBootApplication
public class OrmlearnApplication implements CommandLineRunner {

	@Autowired
	private CountryRepository countryRepository;

	public static void main(String[] args) {
		SpringApplication.run(OrmlearnApplication.class, args);
	}

	@Override
	public void run(String... args) {
		System.out.println("Countries containing 'ou'");
		List<Country> list1 = countryRepository.findByCoNameContaining("ou");
		for (Country c : list1) {
			System.out.println(c.getCoCode() + " " + c.getCoName());
		}

		System.out.println("Countries containing 'ou' sorted ascending");
		List<Country> list2 = countryRepository.findByCoNameContainingOrderByCoNameAsc("ou");
		for (Country c : list2) {
			System.out.println(c.getCoCode() + " " + c.getCoName());
		}

		System.out.println("Countries starting with 'Z'");
		List<Country> list3 = countryRepository.findByCoNameStartingWith("Z");
		for (Country c : list3) {
			System.out.println(c.getCoCode() + " " + c.getCoName());
		}
	}
}
