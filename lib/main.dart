import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:excel/excel.dart';

Future<String> loadAsset(BuildContext context) async {
  return await DefaultAssetBundle.of(context).loadString('LICENSE');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget currentPage = !appState.licenseSee ? LicenseScreen() : DataScreen();

    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
      child: Scaffold(backgroundColor: Colors.transparent, body: currentPage),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var licenseSee = true;
  void licenseSeed() {
    licenseSee = true;
    notifyListeners();
  }
}

enum MyTabs { first, two }

Excel parseExcelFile(List<int> _bytes) {
  return Excel.decodeBytes(_bytes);
}

Future<void> loadFile() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: [
    'xlsx',
  ]);
  if (result != null) {
    var file = result.files.first;
    Excel excel = await compute(parseExcelFile, file.bytes!);
    for (var table in excel.tables.keys) {
      print(table);
    }
  } else {
    // User canceled the picker
  }
}

class DataScreen extends StatefulWidget {
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var fileIsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var theme = Theme.of(context);
    return Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Text(
            "Точка опоры. В личном",
            style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
          Flexible(
              child: FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.5,
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12)),
                          child: TabBar(
                            controller: _tabController,
                            dividerColor: Colors.transparent,
                            tabs: [
                              Container(
                                  // color: _tabController.index == 0
                                  //? theme.primaryColor
                                  //: Colors.transparent,
                                  child: const Tab(
                                text: "Поиск",
                              )),
                              Container(
                                  child: const Tab(
                                text: "Мин./Макс.",
                              ))
                            ],
                          )),
                      SizedBox(
                        height: 46,
                      ),
                      Card(
                        child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Row(
                              children: fileIsLoaded
                                  ? [
                                      Icon(Icons.info_outline_rounded),
                                      SizedBox(
                                        width: 26,
                                      ),
                                      Text(
                                          "Расчёт совместимости партнёров для: \nГамуйло Сергей Сергеевич, 29.12.2004"),
                                      Spacer(),
                                      FilledButton(
                                          onPressed: () {},
                                          child: Text("Инструкция")),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      OutlinedButton(
                                          onPressed: () {},
                                          child: Text("Сбросить"))
                                    ]
                                  : [
                                      Icon(Icons.info_outline_rounded),
                                      SizedBox(
                                        width: 26,
                                      ),
                                      Text(
                                          "Введите Excel файл для продолжения"),
                                      Spacer(),
                                      FilledButton(
                                          onPressed: () => loadFile(),
                                          child: Text("Загрузить файл"))
                                    ],
                            )),
                      ),
                      SizedBox(
                        width: 46,
                      ),
                      // SfDataGrid(source: source, columns: columns)
                    ],
                  )))
        ]));
  }
}

class LicenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var license = loadAsset(context);
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Лицензионное соглашение",
          style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
        SizedBox(
          height: 48,
        ),
        Flexible(
            child: FractionallySizedBox(
                widthFactor: 0.8,
                heightFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: FutureBuilder<String>(
                        future: license,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                                margin: EdgeInsets.all(25),
                                child: Text(
                                  snapshot.data!,
                                  style: TextStyle(fontSize: 22, height: 1.60),
                                ));
                          } else {
                            return Text("");
                          }
                        }),
                  ),
                ))),
        SizedBox(
          height: 48,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
                onPressed: () {
                  appState.licenseSeed();
                },
                child: Text("Я принимаю")),
            SizedBox(
              width: 24,
            ),
            OutlinedButton(onPressed: () {}, child: Text("Лендинг"))
          ],
        ),
      ],
    ));
  }
}
