import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/timetable_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<TimeTable>(
        builder: (context, tt, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: Text('Receive alerts ${tt.notificationOffset} minutes before class starts'),
                      value: tt.notificationsEnabled,
                      onChanged: (bool value) {
                        tt.toggleNotifications(value);
                      },
                    ),
                    if (tt.notificationsEnabled) ...[
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Alert Time'),
                        subtitle: const Text('How early to send the notification'),
                        trailing: DropdownButton<int>(
                          value: tt.notificationOffset,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('At time of class')),
                            DropdownMenuItem(value: 5, child: Text('5 min before')),
                            DropdownMenuItem(value: 10, child: Text('10 min before')),
                            DropdownMenuItem(value: 15, child: Text('15 min before')),
                            DropdownMenuItem(value: 30, child: Text('30 min before')),
                            DropdownMenuItem(value: 60, child: Text('1 hour before')),
                          ],
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              tt.setNotificationOffset(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
