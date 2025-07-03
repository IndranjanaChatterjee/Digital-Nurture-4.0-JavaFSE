package com.example;

public class AlertService {

    private final Notifier notifier;

    public AlertService(Notifier notifier) {
        this.notifier = notifier;
    }

    public void sendAlert(String userId) {
        String msg = "Your session is about to expire!";
        notifier.send(userId, msg);
    }
}
