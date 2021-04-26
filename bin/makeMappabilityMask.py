#!/usr/bin/env python

"""
Authors: Stephan Schiffels, Fred Jaya

Originally from stschiff/msmc-tools
#9302e2ac8c2111cabbf5a1d7296b676adf454c30

Updated to replace hardcoding with command-line arguments
"""

import gzip
import sys
import argparse

class MaskGenerator:
  def __init__(self, filename, chr):
    self.lastCalledPos = -1
    self.lastStartPos = -1
    sys.stderr.write("making mask {}\n".format(filename))
    self.file = gzip.open(filename, "w")
    self.chr = chr
  
  # assume 1-based coordinate, output in bed format
  def addCalledPosition(self, pos):
    if self.lastCalledPos == -1:
      self.lastCalledPos = pos
      self.lastStartPos = pos
    elif pos == self.lastCalledPos + 1:
      self.lastCalledPos = pos
    else:
      self.file.write("{}\t{}\t{}\n".format(self.chr, self.lastStartPos - 1, self.lastCalledPos))
      self.lastStartPos = pos
      self.lastCalledPos = pos

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("workdir", help = "Path to dir containing mask file")
    parser.add_argument("prefix", help = "Organism or project name")
    parser.add_argument("k", help = "k-mer mask size")
    args = parser.parse_args()
    
    mask = "{}/{}_mask.{}.50.fa".format(args.workdir, args.prefix, args.k)
    
    with open(mask, "r") as f:
      for line in f:
        if line.startswith('>'):
          chr = line.split()[0][1:]
    	  out = "{}/{}_{}_mask.bed.gz".format(args.workdir, args.prefix, chr)
          mask = MaskGenerator(out, chr)
          pos = 0
          continue
        for c in line.strip():
          pos += 1
          if pos % 1000000 == 0:
            sys.stderr.write("processing pos:{}\n".format(pos))
          if c == "3":
            mask.addCalledPosition(pos)
