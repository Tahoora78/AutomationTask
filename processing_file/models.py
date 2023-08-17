from django.db import models

class Invoices(models.Model):
    username = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True) 
    pdf_file = models.FileField(null=True)

    # def __str__(self) -> str:
    #     return [self.username, self.pdf_file, self.created_at]