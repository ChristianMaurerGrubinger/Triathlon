# Triathlon
Investigation of the running pattern changes after a long cycling session

Difference between warm and transition run
written by Christian Maurer-Grubinger final version 31.01.2021

TriathlonData is a repository of joint angles from 16 different runners.
Joint anlges are calculated from inertial sensors in a software provided
by the vendor of the devices (xsense) 

segmentation of the running cyclce in individual step cycles was
performed in matlab based on the position data of the foot (heel and toe)
with a treshohld of 2 cm above the local minimum. Every step was time
normalized to 100 points. !! Not the full stride, but the individual
steps were considered, as these are the smallest unique unit (left and 
right can be mirrored to match each other).

Main array of joint angles is the variable:
All_vectors_of_int consisting of 16 subjects x 2 conditions (1st warm,
2nd transition) x 2 sides (1st right 2nd left, trunk angles of the left 
side are mirrored to match the direction of the right side angles).
Every cell contains 10 steps x 3000 angle - dimension - timepoints. 
Only the used 10 angles are provided to reduce file size. Joints were
used in the order: L5S1, L4L3, L1T12, T9T8, active hip, active knee,
active ankle, passive hip, passive knee, passive ankle. Names are storred
in the variable: 

Settings.JointNamesMirrod(UsedJoints)

the dimensions are abduction, rotation, flexion. This is storred in: 

Settings.Dimensionsjoint

the vector of angle - dimension - timepoint is organized as following: 
1st angle of 1st dimension of 1st time point
1st angle of 1st dimension of 2nd time point
...
1st angle of 1st dimension of 100th time point
1st angle of 2nd dimension of 1st time point
...
1st angle of 2nd dimension of 100th time point
1st angle of 3rd dimension of 1st time point
...
1st angle of 3rd dimension of 100th time point
2nd angle of 1st dimension of 1st time point
...


Variables depending on position data were calculated prior to this
script. The calculation for these are not included in this script, but
the values are directly transfered. Especially these variables are:
step length
velocity
frequency
relative stance phase
if you need further insight to the calculation pleas contact:
christian.maurer.cm@gmail.com
