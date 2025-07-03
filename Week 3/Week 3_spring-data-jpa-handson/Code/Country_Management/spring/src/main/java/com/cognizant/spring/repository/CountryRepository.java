package com.cognizant.spring.repository;

import com.cognizant.spring.entity.Country;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CountryRepository extends JpaRepository<Country, String> {
}
