# LIBRARIES / PACKAGES
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from werkzeug.utils import secure_filename
import base64, os, cv2, numpy as np, ShadeClassification
from flask import Flask, request, jsonify
import dlib

class Mouth:
    mouth_roi = None
    teeth_shade = None

m = Mouth

app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'db.sqlite') #
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # suppress SQLALCHEMY_TRACK_MODIFICATIONS warning

db = SQLAlchemy(app)
ma = Marshmallow(app)
app.config['UPLOAD_FOLDER'] = os.path.join(basedir, '../cropped_images')
app.app_context().push()

class Patient(db.Model):
    """
    Fields for Patient Database:
    owner
    name
    contact
    email
    shade
    note
    """
    id = db.Column(db.Integer, primary_key=True)
    owner = db.Column(db.String(100))
    name = db.Column(db.String(100))
    contact = db.Column(db.String(100))
    email = db.Column(db.String(100))
    shade = db.Column(db.String(100))
    note = db.Column(db.String(100))

    def __init__(self, owner, name, contact, email, shade, note):
        self.owner = owner
        self.name = name
        self.contact = contact
        self.email = email
        self.shade = shade
        self.note = note


class ImageAppend (db.Model):
    """
    Fields for Image Database:
    nameID
    name
    owner
    image
    date
    """
    id = db.Column(db.Integer, primary_key=True)
    nameID = db.Column(db.Integer(10000))
    name = db.Column(db.String(100))
    owner = db.Column(db.String(100))
    image = db.Column(db.String(100))
    date = db.Column(db.String(100))

    def __init__(self, nameID, name, owner, image, date):
        self.nameID = nameID
        self.name = name
        self.owner = owner
        self.image = image
        self.date = date



class Note(db.Model):
    """
    Fields for Patient Database:
    owner
    name
    note
    """
    id = db.Column(db.Integer, primary_key=True)
    owner = db.Column(db.String(100))
    name = db.Column(db.String(100))
    note = db.Column(db.String(100))

    def __init__(self, owner, name, note):
        self.owner = owner
        self.name = name
        self.note = note


class PatientSchema(ma.Schema):
    class Meta:
        fields = ('id', 'owner', 'name', 'contact', 'email', 'shade', 'note')

class NoteSchema(ma.Schema):
    class Meta:
        fields = ('id', 'owner', 'name', 'note')

class ImageAppendSchema(ma.Schema):
    class Meta:
        fields = ('id','nameID', 'name', 'owner', 'image', 'date')



patient_schema = PatientSchema()
patients_schema = PatientSchema(many=True)

note_schema = NoteSchema()
notes_schema = NoteSchema(many=True)

imageAppend_schema = ImageAppendSchema()
imageAppends_schema = ImageAppendSchema(many=True)

# Adding a new patient (CREATE)
@app.route('/patient', methods=['POST'])
def add_patient():
    data = request.json
    owner = data['owner']
    name = data['name']
    contact = data['contact']
    email = data['email']
    shade = m.teeth_shade
    note = data['note']
    new_patient = Patient(owner, name, contact, email, shade, note)
    db.session.add(new_patient)
    db.session.commit()
    return patient_schema.jsonify(new_patient)

# Adding a new note (CREATE)
@app.route('/note', methods=['POST'])
def add_note():
    data = request.json
    owner = data['owner']
    name = data['name']
    note = data['note']

    new_note = Note(owner, name, note)
    db.session.add(new_note)
    db.session.commit()
    return note_schema.jsonify(new_note)

# Adding a new image (CREATE)
@app.route('/imageappend', methods=['POST'])
def add_image():
    """
        Fields for Image Database:
        nameID
        name
        owner
        image
        date
    """
    data = request.json
    nameID = data['nameID']
    name = data['name']
    owner = data['owner']
    image = data['image']
    date = data['date']


    new_image = ImageAppend(nameID, name, owner, image, date)
    db.session.add(new_image)
    db.session.commit()
    return patient_schema.jsonify(new_image)

# Query of image according to user
@app.route('/get_image/<owner>', methods=['GET'])
def get_image(owner):
    """
    :param owner:
    :return:


    """


# Conversion of image
@app.route('/images/<path:filename>')
def serve_image(filename):
    with open('images/' + filename, 'rb') as file:
        image_data = file.read()
        base64_image = base64.b64encode(image_data).decode('ascii')
        return {'img': base64_image}


@app.route('/check-image/<path:filename>', methods=['GET'])
def check_image(filename):
    image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.isfile(image_path):
        return jsonify({'success': True, 'message': 'Image found'})
    else:
        return jsonify({'success': False, 'message': 'Image not found'})


# Show all patients for a specific owner (READ)
@app.route('/patient/<owner>', methods=['GET'])
def get_patient(owner):
    patients = Patient.query.filter_by(owner=owner).all()
    result = patients_schema.dump(patients)
    return jsonify(result)

# Show all notes for a specific owner (READ)
@app.route('/note/<owner>', methods=['GET'])
def get_note(owner):
    notes = Note.query.filter_by(owner=owner).all()
    result = notes_schema.dump(notes)
    return jsonify(result)

# Show all patient (READ)
@app.route('/patient',methods=['GET'])
def get_AllPatient():
    all_patients = Patient.query.all()
    result = patients_schema.dump(all_patients)
    return jsonify(result)

# Show all note (READ)
@app.route('/note',methods=['GET'])
def get_AllNote():
    all_notes = Note.query.all()
    result = notes_schema.dump(all_notes)
    return jsonify(result)

# Show patient by ID (READ)
@app.route('/patient/<id>',methods=['GET'])
def get_patient_id(id):
    patient = Patient.query.get(id)
    return patient_schema.jsonify(patient)

# Show note by ID (READ)
@app.route('/note/<id>',methods=['GET'])
def get_note_id(id):
    note = Note.query.get(id)
    return note_schema.jsonify(note)

# Update patient information
@app.route('/patient/<id>',methods=['PUT'])
def update_patient(id):
    patient = Patient.query.get(id)
    name = request.json['name']
    contact = request.json['contact']
    email = request.json['email']
    shade = request.json['shade']
    note = request.json['note']

    patient.name = name
    patient.contact = contact
    patient.email = email
    patient.shade = shade
    patient.note = note

    db.session.commit()
    return patient_schema.jsonify(patient)

# Update note information
@app.route('/note/<id>',methods=['PUT'])
def update_note(id):
    note_ud = Note.query.get(id)
    name = request.json['name']
    note = request.json['note']

    note_ud.name = name
    note_ud.note = note

    db.session.commit()
    return note_schema.jsonify(note_ud)

# Delete a patient by ID (DELETE)
@app.route('/patient/<id>',methods=['DELETE'])
def delete_patient(id):
    patient = Patient.query.get(id)
    db.session.delete(patient)
    db.session.commit()
    return patient_schema.jsonify(patient)

# Delete a note by ID (DELETE)
@app.route('/note/<id>',methods=['DELETE'])
def delete_note(id):
    note = Note.query.get(id)
    db.session.delete(note)
    db.session.commit()
    return note_schema.jsonify(note)



"""
CAMERA OBJECT DETECTION CODE BELOW
THIS IS USED FOR FLUTTER AND THE PROCESSED IMAGE
WILL BE CROPPED AND ADJUSTED ACCORDINGLY.
"""

def landmark(image_data):
    # Load the shape predictor model
    predictor_path = '../shape_predictor_68_face_landmarks.dat'
    predictor = dlib.shape_predictor(predictor_path)

    # Initialize the face detector
    detector = dlib.get_frontal_face_detector()

    # Convert the image data to a numpy array
    nparr = np.frombuffer(image_data, np.uint8)

    # Decode the image array using OpenCV
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Create the output folder if it does not exist
    output_folder = "cropped_images"
    os.makedirs(output_folder, exist_ok=True)

    # Reduce the size of the image
    image_scale = 0.8
    resized_image = cv2.resize(image, (0, 0), fx=image_scale, fy=image_scale)

    # Convert the resized image to grayscale
    gray = cv2.cvtColor(resized_image, cv2.COLOR_BGR2GRAY)

    # Detect faces in the grayscale image
    faces = detector(gray)

    if len(faces) == 0:
        print("No face detected")
        return False
    else:
        for face in faces:
            # Get the facial landmarks for the face
            landmarks = predictor(gray, face).parts()[48:68]

            # Get the mouth region coordinates
            mouth_left = min(landmarks, key=lambda p: p.x).x
            mouth_right = max(landmarks, key=lambda p: p.x).x
            mouth_top = min(landmarks, key=lambda p: p.y).y
            mouth_bottom = max(landmarks, key=lambda p: p.y).y

            # Adjust the cropping region to include more of the mouth area
            crop_margin = 10
            mouth_left -= crop_margin
            mouth_right += crop_margin
            mouth_top -= crop_margin
            mouth_bottom += crop_margin

            # Ensure the cropping region is within the image boundaries
            mouth_left = max(0, mouth_left)
            mouth_right = min(resized_image.shape[1], mouth_right)
            mouth_top = max(0, mouth_top)
            mouth_bottom = min(resized_image.shape[0], mouth_bottom)

            # Determine if the mouth is open with teeth
            # Calculate the width and height of the mouth region
            mouth_width = mouth_right - mouth_left
            mouth_height = mouth_bottom - mouth_top

            # Calculate the threshold for determining an open mouth with teeth
            # If the mouth height is greater than a flexible threshold, it is considered an open mouth
            threshold = 0.5 * mouth_width  # Adjust the threshold value as needed

            is_mouth_open = mouth_height > threshold
            print("Mouth Height",mouth_height)
            print("Threshold:",threshold)
            if (mouth_height > threshold):
                # Crop the mouth region
                mouth_cropped = resized_image[mouth_top:mouth_bottom, mouth_left:mouth_right]

                # Resize the sharpened mouth region to the desired size
                resize_width = 2300
                resize_height = 1400
                mouth_cropped_resized = cv2.resize(mouth_cropped, (resize_width, resize_height))
                m.mouth_roi = mouth_cropped_resized
                return True
            elif ((mouth_height - threshold)<5):
                print("It went here less than 5!")
                return False
            else:
                print("No open mouth detected")
                return False


@app.route('/')
def helloWorld():
    return "Hello! The code works. Now testing for Cropping Image. [This is only for Debugging!]."

@app.route('/detect_smiles', methods=['POST'])
def detect_smiles_endpoint():
    # Get the image file sent from Flutter
    image_file = request.files['image']
    image_data = image_file.read()

    if landmark(image_data) == True:
        print("Face found!")
        return jsonify({'result': 'Success', 'image': "Teeth is detected."})
    elif landmark(image_data) == False:
        print()
        return jsonify({'result': 'Retake', 'msg': "Lacking teeth surface area or No teeth Detected. Try again."})
    else:
        return jsonify({'result': 'Failure', 'message': 'No opened mouth with teeth or face detected.'})

2
# Uploading image
@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No image file uploaded', 400

    image = request.files['image']
    if image.filename == '':
        return 'Invalid image file', 400

    filename = secure_filename(image.filename)
    image_path = os.path.join('../cropped_images', filename)
    image_path = image_path.replace(".jpg","")
    print("The image path is:",image_path)
    cv2.imwrite(image_path+".jpg", m.mouth_roi)

    # Process the image or perform any desired operations
    m.teeth_shade = ShadeClassification.shade(image_path+".jpg")
    print("The teeth shade has been determined:",m.teeth_shade)
    return 'Image uploaded successfully'


if __name__ == '__main__':
    # app.run()
    app.run(host='0.0.0.0')