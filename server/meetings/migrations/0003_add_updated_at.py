from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('meetings', '0002_devicetoken_alter_meeting_options_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='meeting',
            name='updated_at',
            field=models.DateTimeField(auto_now=True),
        ),
        migrations.RenameField(
            model_name='devicetoken',
            old_name='last_used',
            new_name='updated_at',
        ),
    ]
