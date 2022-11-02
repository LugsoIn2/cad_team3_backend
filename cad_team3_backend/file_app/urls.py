from django.urls import path
from . import views

urlpatterns = [
    path('upload/', views.upload, name='file-upload'),
    path('', views.list, name='list')
]