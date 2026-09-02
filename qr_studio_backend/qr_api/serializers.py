from rest_framework import serializers

from .models import QRCode


class QRCodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = QRCode
        fields = ['id', 'qr_type', 'content', 'created_at']