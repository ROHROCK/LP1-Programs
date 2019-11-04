import csv
import random
import math

def loadCsv(filename):
	lines = csv.reader(open(filename,"r"))
    dataset = list(lines)
    for i in range(len(dataset)):
        dataset[i] = [float(data) for data in dataset[i]]
    return dataset

def splitDataSet(dataset,splitRatio):
	trainingSize = int(len(dataset) * splitRatio)
	trainSet = []
	copy = list(dataset)

if __name__ == "__main__":
    dataset = loadCsv("diabetes.csv")
    splitRatio = 0.67
    trainingSet,testingSet = splitDataSet(dataset,splitRatio)
