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


# File Tree Structure 📁
### DASH Root Directory
``` bash
.
├── Flask-server-backend
├── Flutter-mobileapp-frontend
├── README/
│   └── assets/
│       └── arrayco.jpg
└── README.md
```
### Flask-server-backend Subdirectory
``` bash
.Flask-server-backend
├── .idea/
│   ├── inspectionProfiles
│   ├── .gitignore
│   └── array-co.online.iml
├── _pycache_/
│   ├── Classification.cpython-310
│   ├── FeatureExtract.cpython-310
│   ├── main.cpython-310
│   ├── Preprocessing.cpython-310
│   └── ShadeClassification.cpython-310
├── cropped_images
├── images
├── Output
├── venv/
│   ├── include
│   ├── Lib
│   ├── Scripts
│   ├── share
│   ├── .gitignore
│   └── pyvenv
├── Classification.py
├── FeatureExtract.py
├── main.py
├── Mediapipe.py
├── Preprocessing.py
├── requirements.txt
├── ShadeClassification.py
└── svm_model.pkl
```
### Flutter-mobileapp-frontend Subdirectory
``` bash
.Flutter-mobileapp-frontend
├── android/
│   ├── app/
│   │   ├── src
│   │   ├── build
│   │   └── google-services
│   └── assets/
│       ├── fonts
│       ├── icons
│       └── images
└── lib/
    ├── components/
    │   ├── choice_dialog.dart
    │   ├── confirmation_dialog.dart
    │   ├── detail_list.dart
    │   ├── error_alert.dart
    │   ├── home_card.dart
    │   ├── homescreen_list.dart
    │   ├── large_button.dart
    │   ├── login_dialog.dart
    │   ├── medium button.dart
    │   ├── navigation_bar.dart
    │   ├── patient_textfield.dart
    │   └── userinfo textfield.dart
    ├── controllers/
    │   ├── profile_controller.dart
    │   └── registration_controller.dart
    ├── models/
    │   ├── note.dart
    │   ├── patient.dart
    │   ├── todo_item.dart
    │   └── user_model.dart
    ├── providers/
    │   ├── note_api.dart
    │   ├── patientApi.dart
    │   ├── stable_patient_api.dart
    │   └── todo_provider.dart
    ├── repositories/
    │   └── exceptions
    ├── screens/
    │   ├── add note form.dart
    │   ├── add_patient_form.dart
    │   ├── database note screen.dart
    │   ├── database_screen.dart
    │   ├── home screen.dart
    │   ├── image_acquisition.dart
    │   ├── login_screen.dart
    │   ├── note_details.dart
    │   ├── note screen.dart
    │   ├── patient_details.dart
    │   ├── registration_screen.dart
    │   ├── settings_screen.dart
    │   ├── splash_screen.dart
    │   ├── stable_imageacquisition.dart
    │   ├── test.dart
    │   ├── update_note form.dart
    │   ├── update_patient_form.dart
    │   └── update_profile_screen.dart
    └── widgets/
        └── tasks.dart
```
<br>
<br>



# Quick Guide and Start Up 📖
1. Clone the repository to your local machine
     <p> This flutter project can be opened using Android Studio or Visual Studio Code </p>
2. Since the uploaded project in GitHub is tailored for local host, use the local ip address
     <p> This can be found when running the python flask main.py file</p>
3. Before running the python file, make sure to install the requirements.txt first.
3. Run the python flask file (main.py) and then run the flask flutter project.
     <p> The front-end interface to navigate is flutter (mobile app) and the back-end processing will come from python </p>
4. Explore and enjoy!


