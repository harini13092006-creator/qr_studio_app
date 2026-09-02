from django.db import models


class QRCode(models.Model):
    qr_type = models.CharField(max_length=50)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.qr_type} - {self.created_at}"