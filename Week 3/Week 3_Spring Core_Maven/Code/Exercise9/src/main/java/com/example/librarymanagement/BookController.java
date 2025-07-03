package com.example.librarymanagement;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/books")
public class BookController {

    @Autowired
    private BookRepository repo;

    // Get all books
    @GetMapping
    public List<Book> getAllBooks() {
        return repo.findAll();
    }

    // Getby ID
    @GetMapping("/{id}")
    public Book getBookById(@PathVariable Long id) {
        return repo.findById(id).orElse(null);
    }

    // Create
    @PostMapping
    public Book createBook(@RequestBody Book book) {
        return repo.save(book);
    }

    // Update
    @PutMapping("/{id}")
    public Book updateBook(@PathVariable Long id, @RequestBody Book book) {
        book.setId(id);
        return repo.save(book);
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteBook(@PathVariable Long id) {
        repo.deleteById(id);
    }
}
