import os
import errno
import joblib
import cv2 as cv
import numpy as np
import Preprocessing as Pc
import Classification as Cl
import FeatureExtract as Fe

# Define the folder path containing the training images

shades = {
    'a1': '0',
    # 'A1': '0',
    'a2': '1',
    # 'A2': '1',
    'a3': '2',
    # 'A3': '2',
    'a3.5': '3',
    # 'A35': '3',
}

tags = ['0', '1', '2', '3']
target = ['a1', 'a2', 'a3', 'a35']

class Main:
    output_path = "Output"
    dataset_folder = "images"
    
    def __init__(self):
        # Make a directory for the output images
        try:
            self.path_output = os.path.join(os.getcwd(), 'Output')
            if not os.path.exists('Output'):
                os.mkdir('Output')
                print('Output Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('Output Directory Already Exists.')
        
        # Make a directory for the Segmented images
        try:
            self.path_Segmented = os.path.join(self.output_path, 'Segmented')
            if not os.path.exists('Output/Segmented'):
                os.mkdir(os.path.join('Output', 'Segmented'))
                print('Segmented Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('Segmented Directory Already Exists.')

        # Make a directory for the HSV images
        try:
            self.path_HSV = os.path.join(self.output_path, 'HSV')
            if not os.path.exists('Output/HSV'):
                os.mkdir(os.path.join('Output', 'HSV'))
                print('HSV Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('HSV Directory Already Exists.')


    def main(self,frame):
        extract = Fe.FeatureExtraction(self.output_path)
        classify = Cl.Classification(self.output_path, self.dataset_folder)
        preproc = Pc.PreprocessingSteps(self.output_path, self.dataset_folder)

        image_name = frame

        print("[SHADECLASS.] The value of frame should not be null: ",frame)

        if frame == None:
            print("Detection failed!")
        else:
            img_path = frame
            print("New image path: ", img_path)
            # New image path:  cropped_images\cropped_smile8.jpg
            try:
                # set the path for the new image and get the file name
                # new_img_path = os.path.join(os.getcwd(), img_path)
                new_img= cv.imread(img_path)

                # print("New image path: ",img_path)

                print("[SHADE] Preprocess the new image")
                # Preprocess the new image
                new_resized_img = cv.resize(new_img, dsize=None, fx=1/3, fy=1/3, interpolation=cv.INTER_LINEAR)
                new_rgb_img = cv.cvtColor(new_resized_img, cv.COLOR_BGR2RGB)
                new_hsv_img = cv.cvtColor(new_rgb_img, cv.COLOR_RGB2HSV_FULL)
                name, new_blur_img = preproc.blur_image(new_rgb_img, img_path)
                new_mask = preproc.find_contours(new_blur_img)

                print("[SHADE] Extract the red, green, blue features")
                # Extract the red, green, blue features
                ChannelR, ChannelG, ChannelB = cv.split(new_rgb_img)
                red = extract.get_features(ChannelR, new_mask)
                green = extract.get_features(ChannelG, new_mask)
                blue = extract.get_features(ChannelB, new_mask)

                new_img = [red, green, blue]

                print("[SHADE] Write the features to a csv file")
                # Write the features to a csv file
                vector_features = extract.write_new_features(new_img, name)

                print("[SHADE] Delete the garbage values from extracting the features")
                # Delete the garbage values from extracting the features
                vector_features.pop(1)
                vector_features.pop(3)
                vector_features.pop(5)

                print("[SHADE] Convert the list to a numpy array")
                # Convert the list to a numpy array
                vector_features = np.array(vector_features)
                # print('[SHADE]',vector_features)

                print("[SHADE] Test the image from the saved model")
                # Test the image from the saved model
                loaded_model = joblib.load('svm_model.pkl')

                # Predict the shade of the new image
                predicted_shade = loaded_model.predict(vector_features.reshape(1, -1))
                print(f"Predicted Shade: {predicted_shade}")
                print(vector_features.reshape(1, -1))

                # Print the recommended shade and the accuracy of the classification
                for shade, label in shades.items():
                    if label == predicted_shade:
                        print(f"Recommended Shade: {shade}")
                        # Print accuracy2
                        print(f"Accuracy: {loaded_model.score(vector_features.reshape(1, -1), [predicted_shade])}")
                        print('Success')
                        return str(shade.upper())

            except Exception as e:
                print(e)
                print('Error in classifying the image')


def shade(frame):
    obj = Main()  # Create an instance of the Main class
    value = obj.main(frame)  # Call the main() method on the instance
    return value

# print("The shade value: ", shade(frame))

# shade('cropped_images/chris.jpg')


