import 'package:firestore_ref/firestore_ref.dart';
import 'package:flutter/material.dart';
import 'package:Myapp/Pages/addTask.dart';
import 'package:Myapp/Pages/const.dart';
import 'package:Myapp/Service/database.dart';
import 'package:weather/weather.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _weather;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController decControler = TextEditingController();
  Stream? TaskStream;
  String city = "";
  bool data = false;

  Future<void> getTaskDetails() async {
    TaskStream = await DatabaseMethos().gettaskDetails();
    setState(() {
      requestLocationPermission();
    });
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    getTaskDetails();
  }

  requestLocationPermission() async {
    final messanger = ScaffoldMessenger.of(context);
    PermissionStatus status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        String cityName = placemarks.first.locality!;
        city = cityName;

        setState(() {
          _wf.currentWeatherByCityName(cityName).then((w) {
            setState(() {
              _weather = w;
              data = true;
            });
          });
        });
      } catch (err) {
        debugPrint('Error getting city name: $err');
      }
    }
    if (status == PermissionStatus.denied) {
      debugPrint('Permission Denied');
      messanger.showSnackBar(SnackBar(
        content: const Text('Cannot Access Location'),
        action: SnackBarAction(
            label: 'Open App Settings',
            onPressed: () {
              openAppSettings();
            }),
      ));
    }
    if (status == PermissionStatus.limited) {
      debugPrint('Permission is Limited');
    }
  }

  Widget taskDetails() {
    return Column(
      children: [
        _extraInfo(),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "All",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Task's",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Flexible(
            child: StreamBuilder(
                stream: TaskStream,
                builder: (context, AsyncSnapshot snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot ds =
                                snapshot.data.docs[index];
                            String title = ds["Title"];
                            title = title.capitalize();
                            return ListTile(
                              onTap: () {
                                titleControler.text = ds["Title"];
                                decControler.text = ds["Description"];
                                editDetails(ds["Id"]);
                              },
                              leading: Icon(Icons.task),
                              title: Text(title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              subtitle: Text(ds["Description"]),
                            );
                          })
                      : Center(child: CircularProgressIndicator());
                }))
      ],
    );
  }

  Future<void> editDetails(String id) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Edit Task"),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.cancel),
          ),
          SizedBox(
            width: 60,
          )
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleControler,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: decControler,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updateInfo = {
                      "Title": titleControler.text,
                      "Description": decControler.text,
                    };
                    await DatabaseMethos().updatetaskDetails(id, updateInfo);
                    Navigator.pop(context);
                  },
                  child: Text("Update"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await DatabaseMethos().deletetaskDetails(id);
                    Navigator.pop(context);
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "My",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "App",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => addTaskPage())),
        child: Icon(Icons.add),
      ),
      body: Container(margin: EdgeInsets.all(20), child: taskDetails()),
    );
  }

  Widget _extraInfo() {
    return !data
        ? LinearProgressIndicator()
        : Container(
            height: MediaQuery.sizeOf(context).height * 0.15,
            width: MediaQuery.sizeOf(context).width * 0.80,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Temp: ${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "City: ${city} ",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
