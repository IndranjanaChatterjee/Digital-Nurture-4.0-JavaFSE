package com.example;

import org.junit.Test;
import org.mockito.Mockito;

import static org.mockito.Mockito.*;

public class MyServiceTest {

    @Test
    public void testVerifyInteraction() {
        // Create mock
        ExternalApi mockApi = Mockito.mock(ExternalApi.class);

        //Use mock in service
        MyService service = new MyService(mockApi);
        service.fetchData();

        // Verify interaction
        verify(mockApi).getData();
    }
}
