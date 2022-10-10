from django.urls import path
from .views import FileUploadView
from . import views

urlpatterns = [
    path('upload/', FileUploadView.as_view(), name='file-upload'),
    path('', views.FileQueryView.as_view())
]