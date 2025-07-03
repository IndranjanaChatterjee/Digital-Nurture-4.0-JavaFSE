package com.example;

import org.junit.Test;
import static org.mockito.Mockito.*;
import static org.junit.Assert.*;

public class MyServiceTest {

    @Test
    public void testExternalApi() {
        // Mock of the ExternalApi
        ExternalApi mockApi = mock(ExternalApi.class);

        // Stub the getData() method
        when(mockApi.getData()).thenReturn("Mock Data");

        MyService service = new MyService(mockApi);

        String result = service.fetchData();
        assertEquals("Mock Data", result);
    }
}
