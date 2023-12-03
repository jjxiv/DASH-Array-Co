# LIBRARIES / PACKAGES
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from werkzeug.utils import secure_filename
import base64, os, cv2, numpy as np
from flask import Flask, request, jsonify


app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, '../db.sqlite') #
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # suppress SQLALCHEMY_TRACK_MODIFICATIONS warning
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
smile_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_smile.xml')
mouth_roi = ""

db = SQLAlchemy(app)
ma = Marshmallow(app)
app.config['UPLOAD_FOLDER'] = os.path.join(basedir, '../images')
app.app_context().push()

class Patient(db.Model):
    """
    Fields for Patient Database:
    owner
    name
    contact
    email
    shade
    image
    note
    """
    id = db.Column(db.Integer, primary_key=True)
    owner = db.Column(db.String(100))
    name = db.Column(db.String(100))
    contact = db.Column(db.String(100))
    email = db.Column(db.String(100))
    shade = db.Column(db.String(100))
    image = db.Column(db.String(100))
    note = db.Column(db.String(100))

    def __init__(self, owner, name, contact, email, shade, image, note):
        self.owner = owner
        self.name = name
        self.contact = contact
        self.email = email
        self.shade = shade
        self.image = image
        self.note = note

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
        fields = ('id', 'owner', 'name', 'contact', 'email', 'shade', 'image', 'note')

class NoteSchema(ma.Schema):
    class Meta:
        fields = ('id', 'owner', 'name', 'note')


patient_schema = PatientSchema()
patients_schema = PatientSchema(many=True)

note_schema = NoteSchema()
notes_schema = NoteSchema(many=True)

# Adding a new patient (CREATE)
@app.route('/patient', methods=['POST'])
def add_patient():
    data = request.json
    owner = data['owner']
    name = data['name']
    contact = data['contact']
    email = data['email']
    shade = data['shade']
    image = data['image']
    note = data['note']

    new_patient = Patient(owner, name, contact, email, shade, image, note)
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


# Conversion of image
@app.route('/images/<path:filename>')
def serve_image(filename):
    with open('images/' + filename, 'rb') as file:
        image_data = file.read()
        base64_image = base64.b64encode(image_data).decode('ascii')
        return {'img': base64_image}

# Uploading image
@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No image file uploaded', 400

    image = request.files['image']
    if image.filename == '':
        return 'Invalid image file', 400

    filename = secure_filename(image.filename)
    image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    image.save(image_path)

    # Process the image or perform any desired operations

    return 'Image uploaded successfully'

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

# Show all patient (READ)
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
    image = request.json['image']
    note = request.json['note']

    patient.name = name
    patient.contact = contact
    patient.email = email
    patient.shade = shade
    patient.image = image
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
"""

# Function to detect smiles with teeth in the given frame
def detect_smiles(frame):
    # Convert the frame to grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Detect faces in the frame
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    # Iterate over the detected faces
    for (x, y, w, h) in faces:
        # Draw a rectangle around the face
        cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)

        # Get the region of interest (ROI) within the face rectangle
        roi_gray = gray[y:y+h, x:x+w]
        roi_color = frame[y:y+h, x:x+w]

        # Detect smiles in the ROI
        smiles = smile_cascade.detectMultiScale(roi_gray, scaleFactor=1.7, minNeighbors=22, minSize=(25, 25))

        # Iterate over the detected smiles
        for (sx, sy, sw, sh) in smiles:
            # Draw a rectangle around the smile
            cv2.rectangle(roi_color, (sx, sy), (sx+sw, sy+sh), (0, 255, 0), 2)

            # Crop the image within the mouth area
            mouth_roi = roi_color[sy:sy+sh, sx:sx+sw]

            # Get the output image path
            # output_dir = 'images'
            # os.makedirs(output_dir, exist_ok=True)
            # output_path = os.path.join(output_dir, 'cropped_mouth.jpg')

            # Save the cropped mouth area to the output directory
            # cv2.imwrite(output_path, mouth_roi)

        return True

    # If no opened mouth with teeth is detected, return False
    return False


@app.route('/')
def helloWorld():
    return "Hello! The opencv2 code works. [This is only for Debugging!]."

@app.route('/detect_smiles', methods=['POST'])
def detect_smiles_endpoint():
    # Get the image file sent from Flutter
    image_file = request.files['image']
    image_data = image_file.read()

    # Convert the image data to a numpy array
    nparr = np.frombuffer(image_data, np.uint8)

    # Decode the image array using OpenCV
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Perform smile detection   on the image
    if detect_smiles(frame):
        # Encode the result image to base64
        _, img_encoded = cv2.imencode('.jpg', frame)
        img_base64 = base64.b64encode(img_encoded).decode('utf-8')

        return jsonify({'result': 'Success', 'image': img_base64})
    else:
        return jsonify({'result': 'Failure', 'message': 'No opened mouth with teeth detected.'})


if __name__ == '__main__':
    app.run(host='0.0.0.0')