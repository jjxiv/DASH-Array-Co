# DASH: Composite Restoration using Image Recognition for Teeth Shade Matching using Deep Learning

<br>
<p align="center">
  <img src="README/assets/arrayco.jpg" align="middle" width = "1000" />
</p>

# Hi, we are Array Co. 👋
We are a group of researchers from **FEU Institute of Technology** under the course of *Bachelor of Science in Computer Science with Specialization in Software Engineering*.


**Array Co. Members:**
1. Jericho John O. Almoro
2. Francis Dale P. Cañon
3. Bianca H. Goldman
4. Micah Sophia Q. Tan
5. John Angelo B. Yap
<br>


# What is DASH? 🦷📱
Array Co. developed an android applcation which addresses the variability of composite restoration in dentistry and orthodontics by standardizing the crucial step of shade matching using the CNN-based MediaPipe Facial Landmark Detection for object detection and Support Vector Machines for classification. The developed application achieved a remarkable 90% accuracy as validated by dentists, which significantly exceeds the peer-reviewed estimated 35% accuracy of traditional visual shade matching. Also, DASH stands for Dental Application for Shade Matching.
<br>
<br>


# Tools and Frameworks👨‍💻
### Flutter Framework  <img src="https://cdn.worldvectorlogo.com/logos/flutter.svg"  width = "20"/>
Array Co. employed Flutter to build a cross-platform Android mobile application for composite shade matching, leveraging its single codebase for efficient development. Flutter's expressive UI features allowed for the creation of a visually appealing and consistent user interface across devices. The use of Dart programming language and Flutter's hot reload feature likely facilitated a streamlined development process and quick iterations for testing shade matching functionality. Ultimately, choosing Flutter enabled Array Co. to deliver a modern, responsive, and natively-like experience for users on Android devices.

### Python Flask  <img src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/python/python.png"  width = "30"/>
Array Co. utilized the Python Flask framework to power the backend server and handle data processing for their composite shade matching application. Flask, being a lightweight and flexible framework, managed tasks such as data storage, retrieval, and API communication. This backend functionality seamlessly integrated with the Flutter front end, which was responsible for creating a visually appealing and consistent user interface on Android devices. The combined use of Flask and Flutter allowed Array Co. to leverage Python's backend capabilities and Flutter's cross-platform efficiency for a comprehensive application development approach.
<br>
<br>


# File Tree Structure
``` bash
├───android
│   ├───app
│   │   └───src
│   │       ├───debug
│   │       ├───main
│   │       │   ├───kotlin
│   │       │   │   └───com
│   │       │   │       └───example
│   │       │   │           └───dash
│   │       │   └───res
│   │       │       ├───drawable
│   │       │       ├───drawable-v21
│   │       │       ├───mipmap-hdpi
│   │       │       ├───mipmap-mdpi
│   │       │       ├───mipmap-xhdpi
│   │       │       ├───mipmap-xxhdpi
│   │       │       ├───mipmap-xxxhdpi
│   │       │       ├───values
│   │       │       └───values-night
│   │       └───profile
│   └───gradle
│       └───wrapper
├───assets
│   ├───fonts
│   │   └───roboto
│   ├───icons
│   └───images
├───ios
│   ├───Flutter
│   ├───Runner
│   │   ├───Assets.xcassets
│   │   │   ├───AppIcon.appiconset
│   │   │   └───LaunchImage.imageset
│   │   └───Base.lproj
│   ├───Runner.xcodeproj
│   │   ├───project.xcworkspace
│   │   │   └───xcshareddata
│   │   └───xcshareddata
│   │       └───xcschemes
│   └───Runner.xcworkspace
│       └───xcshareddata
├───lib
│   ├───components
│   ├───controllers
│   ├───models
│   ├───providers
│   ├───repositories
│   │   └───exceptions
│   ├───screens
│   └───widgets
├───linux
│   └───flutter
├───macos
│   ├───Flutter
│   ├───Runner
│   │   ├───Assets.xcassets
│   │   │   └───AppIcon.appiconset
│   │   ├───Base.lproj
│   │   └───Configs
│   ├───Runner.xcodeproj
│   │   ├───project.xcworkspace
│   │   │   └───xcshareddata
│   │   └───xcshareddata
│   │       └───xcschemes
│   └───Runner.xcworkspace
│       └───xcshareddata
├───README
│   └───assets
├───web
│   └───icons
└───windows
    ├───flutter
    └───runner
        └───resources

```
<br>
<br>



# Quick Guide and Start Up 📖
1. Clone the repository to your local machine
      <p> This flutter project can be opened using Android Studio or Visual Studio Code </p>
2. Since the uploaded project in GitHub is tailored for local host, use the local ip address
     <p> This can be found when runnig the python flask main.py file</p>
3. Run the python flask file (main.py) and then run the flask flutter project
     <p> The front-end interface to navigate is flutter (mobile app) and the back-end processing will come from python </p>
4. Explore and enjoy!


