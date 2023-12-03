# LIBRARIES / PACKAGES
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from werkzeug.utils import secure_filename
import base64, os, cv2, numpy as np, ShadeClassification,mediapipe as mp

"""

       ============  APP DECLARATION AND  SECTION ============

    -   These include the declaration for the flask server implemented on VPS.
    -   Codes below are only intended for initializing the app and structures that
        can be accessed on the server. 

"""

class Mouth:
    mouth_roi = None
    teeth_shade = None
    temp_shade = None

m = Mouth
app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'db.sqlite') #
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # suppress SQLALCHEMY_TRACK_MODIFICATIONS warning

db = SQLAlchemy(app)
ma = Marshmallow(app)
app.config['UPLOAD_FOLDER'] = os.path.join(basedir, 'cropped_images')
app.app_context().push()




"""

       ============ MODELS AND SCHEMAS SECTION ============

    -   These include the models and schemas for the flask server implemented on VPS.
    -   Codes below are only intended for creating database on sqlite (SQLALCHEMY) for
        database functions and used for CRUD operations.

"""

# Patient MODEL
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

# Note MODEL
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

# Patient SCHEMA
class PatientSchema(ma.Schema):
    class Meta:
        fields = ('id', 'owner', 'name', 'contact', 'email', 'shade', 'note', 'date')

# Note SCHEMA
class NoteSchema(ma.Schema):
    class Meta:
        fields = ('id', 'owner', 'name', 'note')

patient_schema = PatientSchema()
patients_schema = PatientSchema(many=True)
note_schema = NoteSchema()
notes_schema = NoteSchema(many=True)



"""

       ============ ROUTES AND FUNCTIONS SECTION ============
                    
    -   These include the routes for the flask server implemented on VPS.
    -   Codes below are only intended for creating routes and structures that
        can be accessed on the server. 
        
"""

# Basic Debugging Access for Availability
@app.route('/')
def helloWorld():
    return "Hello! The code works. Now testing for server availability. [This is only for Debugging!]."


# Adding a NEW PATIENT
@app.route('/patient', methods=['POST'])
def add_patient():
    data = request.json
    owner = data['owner']
    name = data['name'].title()
    contact = data['contact']
    email = data['email']
    shade = m.teeth_shade
    image = data['image']
    note = data['note']
    date = data['date']
    new_patient = Patient(owner, name, contact, email, shade, image, note, date)
    db.session.add(new_patient)
    db.session.commit()
    return patient_schema.jsonify(new_patient)


# Adding a NEW NOTE
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


# Image CONVERSION BASE64
@app.route('/cropped_images/<path:filename>')
def serve_image(filename):
    with open('cropped_images/' + filename, 'rb') as file:
        image_data = file.read()
        base64_image = base64.b64encode(image_data).decode('ascii')
        return {'img': base64_image}


# CHECKING IMAGE if the file exists
@app.route('/check-image/<path:filename>', methods=['GET'])
def check_image(filename):
    image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.isfile(image_path):
        return jsonify({'success': True, 'message': 'Image found'})
    else:
        return jsonify({'success': False, 'message': 'Image not found'})

# CHECKING PATIENT if the record exsists
@app.route('/patient_exists/<name>/<owner>', methods=['GET'])
def get_patient_exists(name, owner):
    patient = Patient.query.filter_by(name=name, owner=owner).first()
    if patient:
        return jsonify({'exists': True})
    else:
        return jsonify({'exists': False})



# SHOW ALL PATIENTS by OWNER
@app.route('/patient/<owner>', methods=['GET'])
def get_patient(owner):
    patients = Patient.query.filter_by(owner=owner).all()
    result = patients_schema.dump(patients)
    return jsonify(result)


# SHOW ALL NOTES by OWNER
@app.route('/note/<owner>', methods=['GET'])
def get_note(owner):
    notes = Note.query.filter_by(owner=owner).all()
    result = notes_schema.dump(notes)
    return jsonify(result)

# Show ALL PATIENT
@app.route('/patient',methods=['GET'])
def get_AllPatient():
    all_patients = Patient.query.all()
    result = patients_schema.dump(all_patients)
    return jsonify(result)

# Show ALL NOTE
@app.route('/note',methods=['GET'])
def get_AllNote():
    all_notes = Note.query.all()
    result = notes_schema.dump(all_notes)
    return jsonify(result)

# Show PATIENT by ID
@app.route('/patient/<id>',methods=['GET'])
def get_patient_id(id):
    patient = Patient.query.get(id)
    return patient_schema.jsonify(patient)

# Show NOTE by ID
@app.route('/note/<id>',methods=['GET'])
def get_note_id(id):
    note = Note.query.get(id)
    return note_schema.jsonify(note)

# UPDATE PATIENT information
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

# UPDATE NOTE information
@app.route('/note/<id>',methods=['PUT'])
def update_note(id):
    note_ud = Note.query.get(id)
    name = request.json['name']
    note = request.json['note']

    note_ud.name = name
    note_ud.note = note

    db.session.commit()
    return note_schema.jsonify(note_ud)

# DELETE PATIENT by ID
@app.route('/patient/<id>',methods=['DELETE'])
def delete_patient(id):
    patient = Patient.query.get(id)
    db.session.delete(patient)
    db.session.commit()
    return patient_schema.jsonify(patient)

# DELETE NOTE by ID
@app.route('/note/<id>',methods=['DELETE'])
def delete_note(id):
    note = Note.query.get(id)
    db.session.delete(note)
    db.session.commit()
    return note_schema.jsonify(note)


# DETECT SMILE process FUNCTION
def detect_open_mouth(image_data):
    # Initialize the Mediapipe face mesh model
    mp_face_mesh = mp.solutions.face_mesh.FaceMesh(static_image_mode=True, max_num_faces=1)

    # Convert the bytes to a NumPy array
    nparr = np.frombuffer(image_data, np.uint8)

    # Decode the NumPy array as an image
    image_data = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Convert the BGR image to RGB for Mediapipe
    image_rgb = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)

    # Process the image with Mediapipe
    results = mp_face_mesh.process(image_rgb)

    if results.multi_face_landmarks is None:
        print("No face detected")
        return False

    # Get the mouth region points
    mouth_points = [61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291, 61, 78, 87, 178, 88, 95, 180, 181]

    # Get the mouth region coordinates
    landmarks = results.multi_face_landmarks[0].landmark
    image_height, image_width, _ = image_data.shape
    mouth_x = [int(landmarks[point].x * image_width) for point in mouth_points]
    mouth_y = [int(landmarks[point].y * image_height) for point in mouth_points]

    # Calculate the mouth height and width
    mouth_top = min(mouth_y)
    mouth_bottom = max(mouth_y)
    mouth_left = min(mouth_x)
    mouth_right = max(mouth_x)
    mouth_height = mouth_bottom - mouth_top
    mouth_width = mouth_right - mouth_left

    # Determine if the mouth is open with teeth
    # If the mouth height is greater than 30% of the mouth width, it is considered an open mouth
    threshold = 0.4 * mouth_width  # Adjust the threshold value as needed
    is_mouth_open = mouth_height > threshold

    print("Mouth Height:", mouth_height)
    print("Mouth Width:", mouth_width)
    print("Threshold:", threshold)

    if is_mouth_open:
        # Add a margin to the coordinates of the mouth region
        margin_width = int(0.05 * mouth_width)
        mouth_top -= int(0.5 * mouth_height)
        mouth_bottom += int(0.2 * mouth_height)
        mouth_left -= margin_width
        mouth_right += margin_width

        # Ensure the cropping region is     within the image boundaries
        mouth_top = max(0, mouth_top)
        mouth_bottom = min(image_height, mouth_bottom)
        mouth_left = max(0, mouth_left)
        mouth_right = min(image_width, mouth_right)

        # Crop the mouth region
        mouth_cropped = image_data[mouth_top:mouth_bottom, mouth_left:mouth_right]
        resize_width = 2300
        resize_height = 1400
        mouth_cropped_resized = cv2.resize(mouth_cropped, (resize_width, resize_height))

        m.mouth_roi = mouth_cropped_resized
        # Check if mouth_roi is None or empty
        if m.mouth_roi is None or m.mouth_roi.size == 0:
            m.temp_shade = None
            return '[UPLOAD] Mouth region not detected or empty', 400

        # Save as variable
        image = request.files['image']
        if image.filename == '':
            return 'Invalid image file', 400

        filename = secure_filename(image.filename)
        image_path = os.path.join('cropped_images', filename)
        image_path = image_path.replace(".jpg", "")
        print("The image path is:", image_path)
        cv2.imwrite(image_path + ".jpg", m.mouth_roi)

        m.temp_shade = ShadeClassification.shade(image_path+".jpg")
        print("[DETECT-1] m.temp_shade: ",m.temp_shade)

        # Remove the image after processing
        os.remove(image_path + ".jpg")

        print("Image removed:", image_path)
        print("[DETECT] m.mouth_roi value: ", m.mouth_roi)
        print("[DETECT] Mouth detected")
        return True

    print("No open mouth detected")
    return False


# DETECT SMILE return VALUE
@app.route('/detect_smiles', methods=['POST'])
def detect_smiles_endpoint():
    # Get the image file sent from Flutter
    image_file = request.files['image']
    image_data = image_file.read()

    if detect_open_mouth(image_data) == True:
        print("Face found!")
        print("[DETECT] Value of shade: ",m.temp_shade)
        return jsonify({'result': 'Success', 'image': "Teeth is detected. Shade: " + str(m.temp_shade)})

    elif detect_open_mouth(image_data) == False:
        print()
        return jsonify({'result': 'Retake', 'msg': "Lack of teeth surface area or No teeth Detected. Try again."})
    else:
        return jsonify({'result': 'Failure', 'message': 'No opened mouth with teeth or face detected.'})


# UPLOAD Image
@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No image file uploaded', 400

    image = request.files['image']
    if image.filename == '':
        return 'Invalid image file', 400

    try:
        filename = secure_filename(image.filename)
        image_path = os.path.join('cropped_images', filename)
        image_path = image_path.replace(".jpg","")
        print("The image path is:",image_path)
        cv2.imwrite(image_path+".jpg", m.mouth_roi)

        # Check if mouth_roi is None or empty
        if m.mouth_roi is None or m.mouth_roi.size == 0:
            return '[UPLOAD] Mouth region not detected or empty', 400

        # Process the image or perform any desired operations
        m.teeth_shade = ShadeClassification.shade(image_path+".jpg")
        print("The teeth shade has been determined:",m.teeth_shade)
        return 'Image uploaded successfully'
    except Exception as e:
        print(e)
        print('[UPLOAD] Error in uploading the image')
        print('[UPLOAD] Value of m.mouth_roi:',m.mouth_roi)



"""
    MAIN FUNCTION
    Warning: Remove parameter host in app.run() when deploying in the server.
"""
if __name__ == '__main__':
    # app.run()
    app.run(host = '0.0.0.0')