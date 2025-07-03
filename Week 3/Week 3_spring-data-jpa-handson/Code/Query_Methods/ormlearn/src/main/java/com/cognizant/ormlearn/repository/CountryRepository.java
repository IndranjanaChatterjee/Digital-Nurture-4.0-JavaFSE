package com.cognizant.ormlearn.repository;

import com.cognizant.ormlearn.entity.Country;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CountryRepository extends JpaRepository<Country, String> {

    List<Country> findByCoNameContaining(String text);
    List<Country> findByCoNameContainingOrderByCoNameAsc(String text);
    List<Country> findByCoNameStartingWith(String letter);
}
