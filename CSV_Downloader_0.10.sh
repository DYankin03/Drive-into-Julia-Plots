#!/bin/bash
#SBATCH --job-name=download_google_sheet
#SBATCH --output=download_google_sheet_%j.log     # Log file (%j adds job ID)
#SBATCH --error=download_google_sheet_%j.err      # Error file
#SBATCH --time=00:10:00                           # Time limit for the job (HH:>
#SBATCH --partition=short                         # Partition to run on (adjust>
#SBATCH --nodes=1                                 # Number of nodes
#SBATCH --ntasks=1                                # Number of tasks
#SBATCH --cpus-per-task=1                         # CPUs per task
#SBATCH --mem=1G                                  # Memory per node (adjust as >

# +-----------------------------------------------------------------+
# This is a SLURM script to download CSV data from a google drive
# and run these CSV through a data visualization script
#
# Needed files:
#               - CSV_Downloader_[Version_Num].py
#               - GCA_Tool_[Version_Num).jl
#
# CHANGE ALL VARIABLES TO PROPER DIRECTORIES

# Variables
WORKDIR="$HOME/!!![Path/To/Cloned/Directory]!!!"  # !!! Replace with your working directory !!!
FOLDER_ID="!!![GDrive_Folder_ID]!!!"              # !!! Replace with your Google Folder ID  !!!

INPUT_DIR="$WORKDIR/Inputs"                       # Location for Input directory
OUTPUT_DIR="$WORKDIR/Graphs"                      # Location for Output directory

# !!! Replace with file location of .json gdrive credentials file !!!
AUTHENTICATION_FILE="$WORKDIR/!!![Google_Cloud_Project_ID]!!!.json"

# Create working directories (nested within WORKDIR)
mkdir -p "$WORKDIR" "$INPUT_DIR" "$OUTPUT_DIR"  || { echo "Failed to create directory"; exit 1;}

cd "$WORKDIR"

# Run Python script with arguments
python3 CSV_Downloader_0.10.py -f "$FOLDER_ID" -c "$AUTHENTICATION_FILE" -o "$INPUT_DIR"

# Run Julia script with arguments
julia GCA_Tool_0.10.jl --input "$INPUT_DIR" --output "$OUTPUT_DIR"

# Log completion (assuming successful download)
echo "Google Sheet downloaded to: $OUTPUT_DIR"
