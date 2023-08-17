from django.urls import path, include
from . import views

urlpatterns = [
    path('upload_file', views.upload_file, name='upload_file')
]