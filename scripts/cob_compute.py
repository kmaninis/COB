

# ----- Parameters passed to the cluster -------
#$ -S /usr/bin/python
#$ -l h_rt=00:59:00
#$ -l h_vmem=200000M
#$ -o /scratch_net/reinhold/Kevis/logs/
#$ -e /scratch_net/reinhold/Kevis/logs/
#$ -j y

# ----------------- Imports --------------------
import os
import numpy as np
import math
import sys


# ---------------- Functions -------------------
def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

def file_subpart(fname,id_start,id_end):
    lines = [line.strip() for line in open(fname)]
    return lines[id_start:id_end+1]


# ------------- Get the parameters -------------
if len(sys.argv)<4:
  exit(1)
else:
  database = sys.argv[1]
  gt_set   = sys.argv[2]

if len(sys.argv)>3:
  n_jobs = int(sys.argv[3])
else:
  n_jobs = 1

if len(sys.argv)>4:
  code_folder = sys.argv[4]
else:
  code_folder = "/scratch_net/reinhold/Kevis/Software/COB/"

# ---------------- Main code -------------------
if database=="COCO":
    ids_file    = "/srv/glusterfs/jpont/gt_dbs/"+database+"/gt_sets/"+gt_set+".txt"
    im_folder   = "/srv/glusterfs/jpont/gt_dbs/"+database+"/images/"+gt_set+"/"
elif database=="Pascal":
    ids_file    = "/srv/glusterfs/jpont/gt_dbs/"+database+"/gt_sets/"+gt_set+".txt"
    im_folder   = "/srv/glusterfs/jpont/gt_dbs/"+database+"/JPEGImages/"
elif database=="PASCALContext":
    ids_file    = "/srv/glusterfs/jpont/gt_dbs/"+database+"/gt_sets/"+gt_set+".txt"
    im_folder   = "/srv/glusterfs/jpont/gt_dbs/"+database+"/JPEGImages/"
elif database=="BSDS500":
    ids_file    = "/srv/glusterfs/jpont/gt_dbs/"+database+"/gt_sets/"+gt_set+".txt"
    im_folder   = "/srv/glusterfs/jpont/gt_dbs/"+database+"/images/all/"
elif database=="SBD":
    ids_file    = "/srv/glusterfs/jpont/gt_dbs/"+database+"/gt_sets/"+gt_set+".txt"
    im_folder   = "/srv/glusterfs/jpont/gt_dbs/"+database+"/img/"
elif database=="ILSVRC":
    ids_file    = "/srv/glusterfs/jpont/gt_dbs/"+database+"/gt_sets/"+gt_set+".txt"
    im_folder   = "/srv/glusterfs/jpont/gt_dbs/"+database+"/images/"+gt_set+"/"

prop_folder = "/srv/glusterfs/kmaninis/COB-public-new/COB-"+database+"-"+gt_set+"-proposals/"
box_folder  = "/srv/glusterfs/kmaninis/COB-public-new/COB-"+database+"-"+gt_set+"-boxes/"
ucm_folder  = "/srv/glusterfs/kmaninis/COB-public-new/COB-"+database+"-"+gt_set+"-ucm/"
	

task_id = int(os.getenv("SGE_TASK_ID", "0"))
if task_id==0:
    task_id = 1
    n_jobs = 1
if task_id>n_jobs:
    exit(1)

# Create the results folder if necessary (only one of the processes)
if not os.path.exists(prop_folder):
  if task_id==1:
    os.makedirs(prop_folder)
    os.makedirs(box_folder)
    os.makedirs(ucm_folder)


print "Process " + str(task_id) + " out of " + str(n_jobs)

# Get the total number of images
n_ims = file_len(ids_file)

if database=="BSDS500":
	if gt_set=="trainval":
		n_ims = n_ims-1

# Get the positions that this process will handle
jobs_per_child = int(math.floor(float(n_ims)/n_jobs))
remainder = n_ims%n_jobs

# We put the remainder to the first 'remainder' jobs
if task_id<=remainder:
    id_start = (jobs_per_child+1)*(task_id-1)+1
    id_end   = (jobs_per_child+1)*(task_id)
else:
    id_start = (jobs_per_child+1)*remainder + jobs_per_child*(task_id-1-remainder) + 1
    if task_id==n_jobs:
        id_end = n_ims
    else:
        id_end = id_start+jobs_per_child-1

# Run the actual code
os.chdir(code_folder)


#                                                                           cob_list(im_folder, id_file, id_start, id_end, prop_dir, box_dir, ucm_dir)
command_to_run = "/usr/sepp/bin/matlab -nodesktop -nodisplay -nosplash -r \"install;cob_list('"+im_folder+"','"+ids_file+"',"+str(id_start)+","+str(id_end)+",'"+prop_folder+"','"+box_folder+"','"+ucm_folder+"');exit\""
os.system(command_to_run)
#print command_to_run




