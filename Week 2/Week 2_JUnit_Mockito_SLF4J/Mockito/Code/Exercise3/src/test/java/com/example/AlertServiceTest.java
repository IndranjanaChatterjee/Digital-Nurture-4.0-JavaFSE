package com.example;

import org.junit.Test;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.*;

public class AlertServiceTest {

    @Test
    public void testSendAlert_ArgumentMatching() {

        Notifier mockNotifier = mock(Notifier.class);
        AlertService service = new AlertService(mockNotifier);

        // Act
        service.sendAlert("user_101");

        // Verify using argument matchers
        verify(mockNotifier).send(eq("user_101"), contains("expire"));
    }
}
