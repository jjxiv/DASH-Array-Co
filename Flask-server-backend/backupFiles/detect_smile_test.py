import os
import dlib
import cv2

# Load the shape predictor model
predictor_path = 'D:/shape_predictor_68_face_landmarks.dat'
predictor = dlib.shape_predictor(predictor_path)

# Initialize the face detector
detector = dlib.get_frontal_face_detector()

# Load the image
image_path = 'smile7.jpg'
image = cv2.imread(image_path)

# Create the output folder if it does not exist
output_folder = "output"
os.makedirs(output_folder, exist_ok=True)

# Reduce the size of the image
image_scale = 0.5
resized_image = cv2.resize(image, (0, 0), fx=image_scale, fy=image_scale)

# Convert the resized image to grayscale
gray = cv2.cvtColor(resized_image, cv2.COLOR_BGR2GRAY)

# Detect faces in the grayscale image
faces = detector(gray)

if len(faces) == 0:
    print("No faces detected in the image.")
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
        # If the mouth height is greater than half of the mouth width, it is considered an open mouth
        is_mouth_open = mouth_height > 0.5 * mouth_width

        # Store the cropped mouth region if teeth are detected
        if is_mouth_open:
            # Resize the cropped mouth region back to the original size
            mouth_cropped = image[int(mouth_top / image_scale):int(mouth_bottom / image_scale),
                                 int(mouth_left / image_scale):int(mouth_right / image_scale)]

            # Save the cropped mouth region to the output folder
            output_path = os.path.join(output_folder, "cropped_image1.jpg")
            cv2.imwrite(output_path, mouth_cropped)
            print("Cropped mouth region saved successfully to the output folder.")
            break
        else:
            print("Failed to save!")
