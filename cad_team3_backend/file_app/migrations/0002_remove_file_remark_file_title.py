# Generated by Django 4.1.2 on 2022-10-10 15:09

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('file_app', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='file',
            name='remark',
        ),
        migrations.AddField(
            model_name='file',
            name='title',
            field=models.CharField(default='', max_length=30),
        ),
    ]
