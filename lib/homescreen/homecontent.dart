import 'package:flutter/material.dart';
import 'package:project/auth/widgets/toggle_button.dart';
import 'package:project/homescreen/cart.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _healthMode = false;
  @override
  Widget build(BuildContext context) {
    double Topmargin = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: Topmargin),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 15),
              CustomeTextfield(hint: "search your food or restaurant"),
              SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      "assets/images/offer .png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          "Get special discount",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Text(
                        "Up to 50%",
                        style: TextStyle(
                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),

                      SizedBox(
                        height: 38,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("claim now"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildSection("Categories"),
              SizedBox(
                height: 90,

                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (context, index) => SizedBox(width: 15),
                  itemBuilder: (context, index) =>
                      categoryCircle(title: "pizza"),
                ),
              ),
              SizedBox(height: 10),
              _buildSection("Restaurant"),
              SizedBox(
                height: 10,
                child: ListView.separated(
                  itemBuilder: (context, index) => fooditemwidget(),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount: 7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildSection(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        InkWell(
          onTap: () {},
          child: Text(
            "show all",
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Row _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hi nikhil',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on),
                Text(
                  "perinthalmanna",
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color.fromARGB(255, 60, 109, 133),
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          tooltip: _healthMode ? 'Health mode: ON' : 'Health mode: OFF',
          onPressed: () {
            setState(() => _healthMode = !_healthMode);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _healthMode ? 'Health mode enabled' : 'Health mode disabled',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            Icons.health_and_safety,
            size: 30,
            color: _healthMode ? Colors.green : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class fooditemwidget extends StatelessWidget {
  const fooditemwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Colors.black),
      child: Row(
        children: [Image.asset("assets/images/MSG Smash Burgers.png")],
      ),
    );
  }
}

class categoryCircle extends StatelessWidget {
  const categoryCircle({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage("assets/images/Classic Cheese Pizza.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}

class CustomeTextfield extends StatelessWidget {
  const CustomeTextfield({super.key, this.hint});
  final String? hint;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderSide: BorderSide.none),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
