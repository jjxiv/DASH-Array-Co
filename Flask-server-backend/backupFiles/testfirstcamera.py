import os
import cv2

# Load the pre-trained Haar cascade XML files for face and smile detection
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
smile_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_smile.xml')

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

            # Display the cropped mouth area
            cv2.imshow('Cropped Mouth', mouth_roi)

            # Get the output image path
            output_dir = 'test_image_YAP_output'
            os.makedirs(output_dir, exist_ok=True)
            output_path = os.path.join(output_dir, 'cropped_mouth.jpg')

            # Save the cropped mouth area to the output directory
            cv2.imwrite(output_path, mouth_roi)

            return True

    # If no opened mouth with teeth is detected, return False
    return False

# Open the camera
cap = cv2.VideoCapture(0)

while True:
    # Read a frame from the camera
    ret, frame = cap.read()

    # Display the frame
    cv2.imshow('Camera', frame)

    # Check for key press
    key = cv2.waitKey(1)

    # Capture the image when 's' is pressed
    if key == ord('s'):
        # Detect smiles in the captured image
        if detect_smiles(frame):
            # Display the result
            cv2.imshow('Smile Detection', frame)

            # Check for key press
            key2 = cv2.waitKey(0)

            # Save the captured image when 'c' is pressed
            if key2 == ord('c'):
                # Get the output image path
                output_dir = 'test_image_YAP_output'
                os.makedirs(output_dir, exist_ok=True)
                output_path = os.path.join(output_dir, 'captured_image.jpg')

                # Save the captured image to the output directory
                cv2.imwrite(output_path, frame)

                print("Image saved successfully.")
        else:
            print("No opened mouth with teeth detected.")

    # Exit the loop when 'q' is pressed
    elif key == ord('q'):
        break

# Release the camera and close windows
cap.release()
cv2.destroyAllWindows()