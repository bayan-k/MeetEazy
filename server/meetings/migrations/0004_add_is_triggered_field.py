from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('meetings', '0003_add_updated_at'),
    ]

    operations = [
        migrations.AddField(
            model_name='meetingalarm',
            name='is_triggered',
            field=models.BooleanField(default=False),
            preserve_default=False,
        ),
    ]
