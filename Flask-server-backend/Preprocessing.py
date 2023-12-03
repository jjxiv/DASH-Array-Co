import os
import errno
import cv2 as cv
import numpy as np
from matplotlib import pyplot as plt, colors

class PreprocessingSteps:
    
    def __init__(self, output_path, dataset_folder):
        self.output_path = output_path
        self.dataset_folder = dataset_folder
        
        # Make a directory for the resized images
        try:
            self.path_Resized = os.path.join(self.output_path, 'Resized')
            if not os.path.exists('Output/Resized'):
                os.mkdir(os.path.join('Output', 'Resized'))
                print('Resized Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('Resized Directory Already Exists.')
        
        # Make a directory for 3 BarPlotCh images
        try:
            self.path_BarPlotCh1 = os.path.join(output_path, 'Segmented') + '/BarPlotCh1'
            if not os.path.exists('Output/BarPlotCh1'):
                os.mkdir(os.path.join(os.path.join('Output', 'Segmented'), 'BarPlotCh1'))
                print('BarPlotCh1 Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('BarPlotCh1 Directory Already Exists.')
        try:
            self.path_BarPlotCh2 = os.path.join(output_path, 'Segmented') + '/BarPlotCh2'
            if not os.path.exists('Output/BarPlotCh2'):
                os.mkdir(os.path.join(os.path.join('Output', 'Segmented'), 'BarPlotCh2'))
                print('BarPlotCh2 Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('BarPlotCh2 Directory Already Exists.')
        try:
            self.path_BarPlotCh3 = os.path.join(output_path, 'Segmented') + '/BarPlotCh3'
            if not os.path.exists('Output/BarPlotCh3'):
                os.mkdir(os.path.join(os.path.join('Output', 'Segmented'), 'BarPlotCh3'))
                print('BarPlotCh3 Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('BarPlotCh3 Directory Already Exists.')
                
        # Make a directory for countour images    
        try:
            self.path_Contour = os.path.join(self.output_path, 'Segmented') + '/Contour'
            if not os.path.exists('Output/Segmented/Coutour'):
                os.mkdir(os.path.join(os.path.join('Output', 'Segmented'), "Contour"))
                print('Contour Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('Contour Directory Already Exists.')
                
        # Make a directory for masks
        try:
            self.path_Mask = os.path.join(self.output_path, 'Segmented') + '/Mask'
            if not os.path.exists('Output/Segmented/Mask'):
                os.mkdir(os.path.join(os.path.join('Output', 'Segmented'), 'Mask'))
                print('Mask Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('Mask Directory Already Exists.')
                
        # Make a directory for the overlayed images
        try:
            self.path_Overlay = os.path.join(self.output_path, 'Segmented') + '/Overlay'
            if not os.path.exists('Output/Segmented/Overlay'):
                os.mkdir(os.path.join(os.path.join('Output', 'Segmented'), 'Overlay'))
                print('Overlay Directory Created')
        except OSError as e:
            if OSError.errno == errno.EEXIST:
                print('Overlay Directory Already Exists.')


    # Read all images in the folder
    def read_images(self, dataset_folder):
        images = []
        names = []    
        for file in os.listdir(dataset_folder):
            if ('jpg' in file) or ('JPG' in file):
                try:
                    image = cv.imread(os.path.join(dataset_folder, file))
                    images.append(image)
                    names.append(file)
                except Exception as e:
                    print(e)
                    print("Error loading image: " + file)
                    break
        return images, names

    # Resize the image
    def resize_image(self, image, name):
        scale = 1/3
        resized_img = cv.resize(image,dsize=None,fx=scale,fy=scale,interpolation=cv.INTER_LINEAR)
        if os.path.exists(self.path_Resized + "/" + name):
            pass
        else:
            cv.imwrite(self.path_Resized+ "/" + name, resized_img)
        return resized_img
    
    # Convert BGR to RGB
    def bgr2rgb(self, resized_img):
        rgb_img = cv.cvtColor(resized_img, cv.COLOR_BGR2RGB)
        return rgb_img
    
    # Convert to HSV
    def rgb2hsv(self, rgb_img, name):
        hsv_img = cv.cvtColor(rgb_img, cv.COLOR_RGB2HSV_FULL)
        if os.path.exists('Output/HSV/' + name):
            pass
        else:
            cv.imwrite('Output/HSV/' + name, hsv_img)
        return hsv_img
    
    # Stack the images in a barplot
    # pass
    
    # Extract the histograms of the image
    def hist_extract(self, hsv_img, name):
        namefoldersplit = str.split(name, '.')
        namefolder = namefoldersplit[0] 

    # Extract Hue
        plt.figure(figsize=(20, 3))
        hist = cv.calcHist([hsv_img], [0], None, [180], [0, 180])
        plt.xlim([0, 180])
        colours = [colors.hsv_to_rgb((i / 180, 1, 0.9)) for i in range(0, 180)]
        colours = np.array(colours)
        hist = np.array(hist)
        x = list(range(0, 180))
        
        for i in x:
            plt.bar(x[i], hist[i], color=colours[i], edgecolor=colours[i], width=1)
            plt.title('Hue')
        plt.savefig(self.path_BarPlotCh1 + '\\BAR_CHART_HUE_' + name)
            

    # Extract Saturation
        if os.path.exists(self.path_BarPlotCh2 + '\\BAR_CHART_SATURATION_' + name):
            pass
        else:
            plt.figure(figsize=(20, 3))
            hist = cv.calcHist([hsv_img], [1], None, [256], [0, 256])
            plt.xlim([0, 256])
            x = list(range(0, 256))
            colours = [colors.hsv_to_rgb((0, i / 256, 1)) for i in range(0, 256)]

        for i in x:
            plt.bar(x[i], hist[i], color=colours[i], edgecolor=colours[i], width=1)
            plt.title('Saturation')
        plt.savefig(self.path_BarPlotCh2 + '\\BAR_CHART_SATURATION_' + name)
        
        
        # Extract Value
        if os.path.exists(self.path_BarPlotCh3 + '\\BAR_CHART_VALUE_' + name):
            pass
        else:
            plt.figure(figsize=(20, 3))
            hist = cv.calcHist([hsv_img], [2], None, [256], [0, 256])
            plt.xlim([0, 256])
            x = list(range(0, 256))
            colours = [colors.hsv_to_rgb((0, 1, i / 256)) for i in range(0, 256)]
        
        for i in (x):
            plt.bar(x[i], hist[i], color=colours[i], edgecolor=colours[i], width=1)
            plt.title('Value')
        plt.savefig(self.path_BarPlotCh3 + '\\BAR_CHART_VALUE_' + name)
        plt.close('all')
        
    # Blur image // Pass rgb_img
    def blur_image(self, rgb_img, name):
        blur_img = cv.GaussianBlur(rgb_img, (7, 7), 0)
        blur_img_hsv = cv.cvtColor(blur_img, cv.COLOR_RGB2HSV)
        min_red = np.array([10, 0, 0])
        max_red = np.array([40, 255, 255])
        red_img = cv.inRange(blur_img_hsv, min_red, max_red)
        kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (15, 15))
        red_img_closed = cv.morphologyEx(red_img, cv.MORPH_CLOSE, kernel)
        img_red_final = cv.morphologyEx(red_img_closed, cv.MORPH_OPEN, kernel)
        return name, img_red_final
        
    # Find contours // Pass img_red_final
    def find_contours(self, img_red_final):
        img_copy = img_red_final.copy()
        contours, hierarchy = cv.findContours(img_copy, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
        largest_countour = max(contours, key=cv.contourArea)
        mask = np.zeros(img_copy.shape, np.uint8)
        cv.drawContours(mask, [largest_countour], -1, 255, -1)
        return mask
        # cv.imwrite(path_Contour + '\\CONTOUR_' + name, resized_img)

    
# Create a mask
    def create_mask(self, img_red_final, name):
        namefoldersplit = str.split(name, '.')
        namefolder = namefoldersplit[0]
        plt.figure(figsize=(10, 10))
        plt.imshow(img_red_final, cmap='gray')
        plt.savefig(self.path_Mask + '\\MASK_' + name)
        plt.close('all')
        
    # Overlay the mask on the image
    def overlay_mask(self, img_red_final, rgb_img, name):
        namefoldersplit = str.split(name, '.')
        namefolder = namefoldersplit[0]
        rgb_mask = cv.cvtColor(img_red_final, cv.COLOR_GRAY2RGB)
        img = cv.addWeighted(rgb_mask, 0.5, rgb_img, 0.5, 0)
        plt.imshow(img)
        plt.savefig(self.path_Overlay + '\\OVERLAY_' + name)
        plt.close('all')
        
        
    # Renames all image in the folder
    # def rename_files(self)
    #     for folder in os.listdir(self.dataset_folder):
    #             # Loop through the images in the subfolder
    #         for image in os.listdir(self.dataset_folder):
    #             # Rename the files in order to avoid duplicates
    #             os.rename(self.dataset_folder + '/' + image, self.dataset_folder + '/' + '101_' + '{:04d}'.format(i+1) + '.jpg')
    #             # Write the renamed file to the CSV file
    #             # f.write('101_' + '{:04d}'.format(i+1)+ ',' + folder + '\n')
    #             i += 1
                