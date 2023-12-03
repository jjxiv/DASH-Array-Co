import os
import numpy as np
from scipy import stats

class FeatureExtraction:
    
    def __init__(self, output_path):
        self.output_path = output_path
    
    # Save the features in a csv file, create one if none exists
    def write_features(self, image, name):
        if not (os.path.exists(self.output_path + '\\features.csv') or os.path.isfile(self.output_path + '\\features.csv')):
            file = open(self.output_path + '\\features.csv', 'w')
        else:
            file = open(self.output_path + '\\features.csv', 'a')
        
        vector_features = []
        for j in range(0, len(image)):
            vector_features.append(self.meanVector(image[j]))
            vector_features.append(self.varVector(image[j]))
            vector_features.append(self.skewVector(image[j]))
        file.write(name)
        
        for item in range(len(vector_features)):
            file.write(",%.6f" % vector_features[item])
        file.write("\n")  
        file.close()
        
    def meanVector(self, image):
        return np.mean(image)

    def varVector(self, image):
        return stats.moment(image)

    def skewVector(self, image):
        return stats.skew(image)
    
    # Get features
    def get_features(self, channel, mask):
        features = []
        img_copy = channel.copy()
        for i in range(len(mask)):
            for j in range(len(mask[i])):
                if (j == 255):
                    features.append(img_copy[i][j])
        return features
    
    # Write the new features in a csv file
    def write_new_features(self, image, name):
        if not (os.path.exists(self.output_path + '\\new_features.csv') or os.path.isfile(self.output_path + '\\new_features.csv')):
            file = open(self.output_path + '\\new_features.csv', 'w')
        else:
            file = open(self.output_path + '\\new_features.csv', 'a')
        
        vector_features = []
        for j in range(0, len(image)):
            vector_features.append(self.meanVector(image[j]))
            vector_features.append(self.varVector(image[j]))
            vector_features.append(self.skewVector(image[j]))
        file.write(name)
        
        for item in range(len(vector_features)):
            file.write(",%.6f" % vector_features[item])
        file.write("\n")  
        file.close()
        return vector_features
        
    def meanVector(self, image):
        return np.mean(image)

    def varVector(self, image):
        return stats.moment(image)

    def skewVector(self, image):
        return stats.skew(image)