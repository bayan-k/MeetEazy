from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('meetings', '0004_add_is_triggered_field'),
    ]

    operations = [
        migrations.AddField(
            model_name='meetingalarm',
            name='is_sent',
            field=models.BooleanField(default=False),
        ),
    ]
