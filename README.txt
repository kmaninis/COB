
IMPORTANT
 - Install the version of Caffe along with the standard dependencies and matcaffe from https://github.com/s9xie/hed
 - Download the COB model(s) and put them under models/ (~120MB):
  1. Model trained on PASCALContext train (VOC train) set https://data.vision.ee.ethz.ch/kmaninis/share/COB/Downloads/COB_PASCALContext_train.zip
  2. Model trained on PASCALContext trainval set (VOC train + val) https://data.vision.ee.ethz.ch/kmaninis/share/COB/Downloads/COB_PASCALContext_trainval.zip
  3. Model trained on BSDS500 trainval set https://data.vision.ee.ethz.ch/kmaninis/share/COB/Downloads/COB_BSDS500.zip

FIRST INSTALL
- Change datasets/database_root_dir.m to point to your PASCALContext folder (the one with subfolders ImageSets, JPEGImages, etc.) or the BSDS or COCO folders
- Change set_params.m to point to Caffe and choose the mode (GPU or CPU)
- Run install.m from the root dir to add the needed paths and do some checks
- If you need to re-build the library (the script install.m will tell if needed), run build.m

USAGE INSTALL
- Each time you restart your matlab, run install.m
- If you want to avoid this, add the paths permanently

COB USAGE
- To compute COB UCMs, see im2ucm.m (and scripts/im2cob_all.m)
- To compute COB proposals, see im2prop.m (and scripts/im2cob_all.m)
- For demos about how to use these functions, see the 'demos' folder

Enjoy!
