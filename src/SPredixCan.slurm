#!/bin/bash
#SBATCH --job-name=job_array
#SBATCH --array=0-1800
#SBATCH --time=12:00:00
#SBATCH --nodes=1

# directory where the entires are split by chromosome and metabolite
# dir="/ru-auth/local/home/akhan01/GeneMAP/METSIM/"
dir="/ru-auth/local/home/akhan01/GeneMAP/Canadian_ByChromosome"
cd $dir
arr=( $(ls) )

organ_list="Adipose_Subcutaneous Whole_Blood Pancreas Liver Small_Intestine_Terminal_Ileum Kidney_Cortex Colon_Sigmoid Colon_Transverse Muscle_Skeletal Stomach Nerve_Tibial Artery_Tibial Adipose_Visceral_Omentum Adrenal_Gland Artery_Aorta Artery_Coronary Artery_Tibial Brain_Amygdala Brain_Anterior_cingulate_cortex_BA24 Brain_Caudate_basal_ganglia Brain_Cerebellar_Hemisphere  Brain_Cerebellum Brain_Cortex Brain_Frontal_Cortex_BA9 Brain_Hippocampus  Brain_Hypothalamus Brain_Nucleus_accumbens_basal_ganglia Brain_Putamen_basal_ganglia  Brain_Spinal_cord_cervical_c-1  Brain_Substantia_nigra  Breast_Mammary_Tissue  Cells_Cultured_fibroblasts Cells_EBV-transformed_lymphocytes  Esophagus_Gastroesophageal_Junction  Esophagus_Mucosa  Esophagus_Muscularis  Heart_Atrial_Appendage  Heart_Left_Ventricle  Lung  Minor_Salivary_Gland Ovary Pituitary Prostate Skin_Not_Sun_Exposed_Suprapubic  Skin_Sun_Exposed_Lower_leg Spleen Testis Thyroid Uterus Vagina"

# METSIM
#for fn in ${organ_list}; do
#    Organ=$fn
#    srun python /ru-auth/local/home/akhan01/GeneMAP/MetaXcan/software/SPrediXcan.py \
#    --model_db_path /ru-auth/local/home/akhan01/GeneMAP/JTI/JTI_${Organ}.db \
#    --covariance /ru-auth/local/home/akhan01/GeneMAP/JTI/JTI_${Organ}.txt.gz \
#    --gwas_folder ${dir}/${arr[ ${SLURM_ARRAY_TASK_ID} ]  } \
#    --gwas_file_pattern ".*txt" \
#     --snp_column RSID \
#     --effect_allele_column EA \
#     --non_effect_allele_column NEA \
#     --beta_column BETA \
#     --pvalue_column LOGPVALUE \
#    --output_file /ru-auth/local/home/akhan01/GeneMAP/Results_METSIM/${Organ}_METSIM/${arr[ ${SLURM_ARRAY_TASK_ID} ]}_${Organ}_METSIM.csv \
#    --additional_output 
# done

# CLSA

for fn in ${organ_list}; do
     Organ=$fn
     srun python /ru-auth/local/home/akhan01/GeneMAP/MetaXcan/software/SPrediXcan.py \
     --model_db_path /ru-auth/local/home/akhan01/GeneMAP/JTI/JTI_${Organ}.db \
     --covariance /ru-auth/local/home/akhan01/GeneMAP/JTI/JTI_${Organ}.txt.gz \
     --gwas_folder ${dir}/${arr[ ${SLURM_ARRAY_TASK_ID} ]  } \
     --gwas_file_pattern ".*txt" \
     --snp_column variant_id \
     --effect_allele_column effect_allele \
     --non_effect_allele_column other_allele \
     --beta_column beta \
     --pvalue_column p_value \
     --output_file /ru-auth/local/home/akhan01/GeneMAP/Results_Canadian${Organ}_Canadian/${arr[ ${SLURM_ARRAY_TASK_ID} ]}_${Organ}_Canadian.csv \
     --additional_output 
done







