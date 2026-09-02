from django.urls import path

from .views import (
    create_qr,
    qr_history,
    get_qr,
    delete_qr,
)


urlpatterns = [

    path(
        'create/',
        create_qr,
        name='create_qr'
    ),

    path(
        'history/',
        qr_history,
        name='qr_history'
    ),

    path(
        '<int:pk>/',
        get_qr,
        name='get_qr'
    ),

    path(
        '<int:pk>/delete/',
        delete_qr,
        name='delete_qr'
    ),
]