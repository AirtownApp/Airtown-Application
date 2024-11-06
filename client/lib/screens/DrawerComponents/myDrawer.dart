// Refers to https://oflutter.com/create-a-sidebar-menu-in-flutter/
import 'package:airtown_app/screens/Surveys/Preference_Survey.dart';
import 'package:airtown_app/screens/DrawerComponents/about_us_page.dart';
import 'package:airtown_app/screens/DrawerComponents/policies_page.dart';
import 'package:flutter/material.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:airtown_app/screens/Surveys/Health_Survey.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(commons.username),
            accountEmail: Text(commons.email),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/4/41/Profile-720.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: const DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Colors.cyan,
            ),
            title: Text('About Us'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyAboutUsPage())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Color.fromARGB(255, 255, 234, 47),
            ),
            title: const Text('Policies (Info)'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyPoliciesPage())),
          ),
          ListTile(
            leading: Icon(
              Icons.edit_note,
              color: commons.healthSurveyCompleted == false
                  ? Colors.red
                  : Colors.green,
            ),
            title: const Text('Health Survey'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthSurvey(),

                //  datas: detailsData) //, sensordetails: details)
                //SensorDetails(todo: todos[index]),
              ),
            ),
            trailing: commons.healthSurveyCompleted == false
                ? ClipOval(
                    child: Container(
                      color: Colors.red,
                      width: 20,
                      height: 20,
                      child: const Center(
                        child: Text(
                          '', //'8',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                : ClipOval(
                    child: Container(
                      color: Colors.green,
                      width: 20,
                      height: 20,
                      child: const Center(
                        child: Text(
                          '', //'8',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          ListTile(
            leading: Icon(
              Icons.edit_note,
              color: Colors.green,
            ),
            title: const Text('Preference Survey'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreferenceSurvey(),

                //  datas: detailsData) //, sensordetails: details)
                //SensorDetails(todo: todos[index]),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => null,
          ),
        ],
      ),
    );
  }
}
