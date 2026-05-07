#!/bin/bash

gnuplot -e "
  set terminal dumb size 130,40;
  set datafile separator ',';
  set title 'Daily Sales - Bar Graph';
  set xlabel 'Day';
  set ylabel 'Sales';
  set grid;
  set key outside;
  plot 'data.csv'
"
