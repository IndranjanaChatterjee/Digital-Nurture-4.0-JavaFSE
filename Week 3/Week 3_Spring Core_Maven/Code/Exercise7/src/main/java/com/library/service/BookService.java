package com.library.service;

import com.library.repository.BookRepository;

public class BookService {
    private String serviceName;
    private BookRepository bookRepository;

    // Constructor injection
    public BookService(String serviceName) {
        this.serviceName = serviceName;
        System.out.println("Constructor injection called");
    }

    // Setter injection
    public void setBookRepository(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
        System.out.println("Setter injection called");
    }

    public void serv() {
        System.out.println("Service Name: " + serviceName);
        bookRepository.loadBooks();
    }
}
