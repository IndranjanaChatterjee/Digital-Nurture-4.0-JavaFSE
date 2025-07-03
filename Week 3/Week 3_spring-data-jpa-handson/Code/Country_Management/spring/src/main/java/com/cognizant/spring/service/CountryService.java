package com.cognizant.spring.service;

import com.cognizant.spring.entity.Country;
import com.cognizant.spring.repository.CountryRepository;
import com.cognizant.spring.service.exception.CountryNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class CountryService {

    @Autowired
    private CountryRepository countryRepository;

    @Transactional
    public Country findCountryByCode(String code) {
        Optional<Country> result = countryRepository.findById(code);
        if (!result.isPresent()) {
            throw new CountryNotFoundException("Country not found: " + code);
        }
        return result.get();
    }

    @Transactional
    public void addCountry(Country country) {
        countryRepository.save(country);
    }

    @Transactional
    public void updateCountry(String code, String newName) {
        Optional<Country> result = countryRepository.findById(code);
        if (!result.isPresent()) {
            throw new CountryNotFoundException("Cannot update. Country not found: " + code);
        }
        Country country = result.get();
        country.setCoName(newName);
        countryRepository.save(country);
    }

    @Transactional
    public void deleteCountry(String code) {
        if (!countryRepository.existsById(code)) {
            throw new CountryNotFoundException("Cannot delete. Country not found: " + code);
        }
        countryRepository.deleteById(code);
    }
}
