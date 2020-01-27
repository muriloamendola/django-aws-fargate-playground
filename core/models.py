from django.db import models

class Client(models.Model):
    name = models.CharField(max_length=60)
    email = models.EmailField(max_length=100)


    def __str__(self):
        return self.name
