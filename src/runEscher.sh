#!/bin/bash
cd ~/polarimetryLab/src
until escher --serve; do
	echo restarting...!
done
