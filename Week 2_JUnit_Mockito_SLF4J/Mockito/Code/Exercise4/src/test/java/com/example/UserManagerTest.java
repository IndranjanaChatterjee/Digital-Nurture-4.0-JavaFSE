package com.example;

import org.junit.Test;
import static org.mockito.Mockito.*;

public class UserManagerTest {

    @Test
    public void testEmailSentOnRegistration() {
        EmailService mockEmailService = mock(EmailService.class);
        UserManager manager = new UserManager(mockEmailService);

        // Call the method under test
        manager.registerUser("test@example.com");

        // Verify the void method was called
        verify(mockEmailService).sendEmail(
                eq("test@example.com"),
                eq("Welcome!"),
                eq("Thanks for registering.")
        );
    }
}
