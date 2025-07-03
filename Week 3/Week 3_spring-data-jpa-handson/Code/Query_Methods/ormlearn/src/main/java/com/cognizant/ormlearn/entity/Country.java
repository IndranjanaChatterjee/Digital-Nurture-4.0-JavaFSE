package com.cognizant.ormlearn.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class Country {

    @Id
    private String coCode;
    private String coName;

    public String getCoCode() {
        return coCode;
    }

    public void setCoCode(String coCode) {
        this.coCode = coCode;
    }

    public String getCoName() {
        return coName;
    }

    public void setCoName(String coName) {
        this.coName = coName;
    }
}
