from django.urls import path
from .views import FileView
from . import views

urlpatterns = [
    path('upload/', FileView.as_view(), name='file-upload'),
    path("", views.get_files, name="files"),
]