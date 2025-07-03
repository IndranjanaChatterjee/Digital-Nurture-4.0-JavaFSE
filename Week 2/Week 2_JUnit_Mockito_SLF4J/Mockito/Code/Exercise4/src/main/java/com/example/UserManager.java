package com.example;

public class UserManager {

    private final EmailService emailService;

    public UserManager(EmailService emailService) {
        this.emailService = emailService;
    }

    public void registerUser(String email) {
        String subject = "Welcome!";
        String body = "Thanks for registering.";
        emailService.sendEmail(email, subject, body);
    }
}
