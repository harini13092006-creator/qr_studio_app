from django.contrib import admin
from django.urls import path, include


urlpatterns = [

    path(
        'admin/',
        admin.site.urls
    ),

    path(
        'api/qr/',
        include('qr_api.urls')
    ),
]