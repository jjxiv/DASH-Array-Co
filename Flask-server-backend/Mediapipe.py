import cv2
import mediapipe as mp
import os

def detect_open_mouth(image_data):
    # Initialize the Mediapipe face mesh model
    mp_face_mesh = mp.solutions.face_mesh.FaceMesh(static_image_mode=True, max_num_faces=1)

    # Convert the BGR image to RGB for Mediapipe
    image_rgb = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)

    # Process the image with Mediapipe
    results = mp_face_mesh.process(image_rgb)

    if results.multi_face_landmarks is None:
        print("No face detected")
        return False, None

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
    threshold = 0.3 * mouth_width  # Adjust the threshold value as needed
    is_mouth_open = mouth_height > threshold

    print("Mouth Height:", mouth_height)
    print("Mouth Width:", mouth_width)
    print("Threshold:", threshold)

    if is_mouth_open:
        # Add a margin to the coordinates of the mouth region
        margin_width = int(0.1 * mouth_width)
        mouth_top -= int(0.7 * mouth_height)
        mouth_bottom += int(0.4 * mouth_height)
        mouth_left -= margin_width
        mouth_right += margin_width

        # Ensure the cropping region is within the image boundaries
        mouth_top = max(0, mouth_top)
        mouth_bottom = min(image_height, mouth_bottom)
        mouth_left = max(0, mouth_left)
        mouth_right = min(image_width, mouth_right)

        # Crop the mouth region
        mouth_cropped = image_data[mouth_top:mouth_bottom, mouth_left:mouth_right]

        # Save as variable


        print("Mouth detected")
        return True, mouth_cropped

    print("No open mouth detected")
    return False
