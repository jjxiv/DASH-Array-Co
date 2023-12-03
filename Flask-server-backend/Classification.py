import numpy as np
import pandas as pd
from sklearn import svm
from sklearn.model_selection import train_test_split
from sklearn.model_selection import train_test_split, KFold

class Classification:
    
    def __init__(self, output_path, dataset_folder):
        self.output_path = output_path
        self.dataset_folder = dataset_folder
    
    # Reading features from the features.csv file
    def read_features(self):
        try:
            feature_file = pd.read_csv(self.output_path + '\\features.csv', sep=',', header=None)
            # print(feature_file)
            names = feature_file.iloc[:, 0]
            features = feature_file.iloc[:, 1:]
            file_shape = feature_file.shape
            col = []
            for x in range(0, file_shape[1]):
                if x == 0:
                    col.append('Name')
                else:
                    col.append('Value' + str(x))
            feature_file.columns = col
            return names, features
        except Exception as e:
            print(e)
            print("CSV file not found.")

    # Read the labels of the dataset from CSV
    def read_labels(self):
        labels = pd.read_csv(self.output_path + '\\labels.csv', sep=',', header=[0])
        return labels
    
    # split the dataset into training and testing sets
    def split_dataset(self, features, labels, test_size, random_state):
        X = []
        y = []
        X_train, X_test, y_train, y_test = train_test_split(features, labels, test_size=test_size, random_state=random_state)
        X.append(X_train)
        X.append(X_test)
        y.append(y_train)
        y.append(y_test)
        return X, y
        
    # Prepare the train and test data
    def prepare_data(self, X, y, shades):
        # # Prepare the train and test data
            train_features = np.array(X[0])
            test_features = np.array(X[1])
            y[0]['Color'] = y[0]['Color'].map(shades)
            y[1]['Color'] = y[1]['Color'].map(shades)
            test_labels = np.array(y[1]['Color'])
            train_label = np.array(y[0]['Color']) 
            return train_features, test_features, train_label, test_labels

    # Train the model
    def train_model(self, train_features, train_label):
        # Start classification
        clf = svm.SVC(kernel='linear', C=1, gamma=1)
        clf.fit(train_features, train_label)
        return clf