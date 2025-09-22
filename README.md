# eDNA_metabarcoding_Upload-to-GBIF

## Description
The script can be used for eDNA metabarcoding data generated using the DADA2 pipeline (Callahan et al., 2016) from v.1.20.0 onwards. Taxonomic assignment has been done using an in-house RScript, combining the results from the taxonomic assignment using the RDP classifier in DADA2 (bootstrap min 80) and BLASTn against a custom reference database, and BLASTn against the nucleotide collection from the National Center for Biotechnology Information (NCBI). The demultiplexed and trimmed sequencing data and sample metadata are uploaded onto the Sequence Read Archive (SRA) using the MIMARKS template for Biosample registration.

This script allows you to create the dataset file, in excel format, needed to upload eDNA metabarcoding data into the Metabarcoding Data Toolkit (MDT) (https://mdt.gbif.org) to publish DNA metabarcoding data to the Global Biodiversity Information Facility (GBIF).\
The template file, in excel format, consists of 4 sheets:
* Sheet1 = OTU_table\
Contains the OTU or ASV (OUT/ASV) table, in which each row must represent a unique OTU/ASV, and each column must represent a different sample or site, with the cell values indicating the count of sequencing reads of the OTUs/ASVs in each sample. The OTU/ASV table will be linked to two other tables:\
&emsp; - table Taxonomy through the column id, containing the OTU/ASV names\
&emsp; - table Samples through the column id, containing the colnames of the OTU/ASV table
* Sheet2 = Taxonomy\
The taxonomy table (taxa) is connected to the OTU/ASV table and must contain at least the sequence, but ideally also the taxonomic classification. The order of the OTUs/ASVs in the OTU and taxonomy table must be the same 
* Sheet3 = Samples\
The samples table contains the metadata relating to the samples/sites. The order of the samples in the OTU-table (columns) and samples table (rows) must be the same 
* Sheet4 = Study\
Table to add the values you want to add in GBIF, such as target sequence, used primers and sequencing method, etc

## Needed input files
1. OTU_table: [Example File: table_unrarefied_concatenated_CleanedASVs_WithField_FullTaxonomicAssignment.xlsx](https://github.com/icornelis90-ilvo/ILVO-MGL_eDNA_Upload_metabarcodingdata_to_GBIF/blob/main/Input_files/table_unrarefied_concatenated_CleanedASVs_WithField_FullTaxonomicAssignment.xlsx)\
OTU/ASV table containing the unrarefied and concatenated data after decontamination of the contaminant OTUs/ASVs.\
Rows are the OTUs/ASVs and the columns are the samples\
In our dataset the OTU/ASV table also contains the taxonomic classification, OTU/ASV-name, and additional information about the taxonomic assignment. These additional columns have to be removed.
2. ASVs: [Example File: asvs.tsv](https://github.com/icornelis90-ilvo/ILVO-MGL_eDNA_Upload_metabarcodingdata_to_GBIF/blob/main/Input_files/asvs.tsv)\
This table is generated while running the DADA2 pipeline and contains:\
&emsp; - ASV-names (names)\
&emsp; - ASV-sequences (dnas)\
&emsp; - ASV-lengths (len)
3. Attributes_Full: [Example File: Attributes_NJ2021_12S.xlsx](https://github.com/icornelis90-ilvo/ILVO-MGL_eDNA_Upload_metabarcodingdata_to_GBIF/blob/main/Input_files/Attributes_NJ2021_12S.xlsx)\
The complete MIMARKS Survey related template for water samples (MIMARKS: survey, water; version 6.0, https://www.ncbi.nlm.nih.gov/biosample/docs/templates/packages/MIMARKS.survey.water.6.0.xlsx) used to upload the sequencing data to SRA on NCBI.
4. SRR:\
The metadata file containing the BioSample accession and SRR accession numbers, which can be downloaded from NCBI (https://www.ncbi.nlm.nih.gov/). A detailed explanation can be found in the [PDF-file How-to-download-the-RunMetadata](https://github.com/icornelis90-ilvo/ILVO-MGL_eDNA_Upload_metabarcodingdata_to_GBIF/blob/main/How-to-download-the-RunMetadata.pdf). In short, there are two methods for downloading the metadata.\
<ins>Option 1:</ins> [Example File: SraRunInfo_NJ2021_Option1-File.csv](https://github.com/icornelis90-ilvo/ILVO-MGL_eDNA_Upload_metabarcodingdata_to_GBIF/blob/main/Input_files/SraRunInfo_NJ2021_Option1-File.csv) \
If you want to download the metadata from all the submissions in the BioProject, select the SRA database, enter the BioProject accession number in the Entrez query and click search. Then, click **Send to** on the top of the page, check the **File** radiobutton, and select **RunInfo** in the pull-down menu. This will generate a tabular **SraRunInfo.csv** file with metadata available for each Run within the BioProject of interest.\
<ins>Option 2:</ins> [Example File: SraRunTable_NJ2021_Option2-RunSelector.csv](https://github.com/icornelis90-ilvo/ILVO-MGL_eDNA_Upload_metabarcodingdata_to_GBIF/blob/main/Input_files/SraRunTable_NJ2021_Option2-RunSelector.csv) \
If you want to download the metadata from all the submissions in the BioProject, select the SRA database, enter the BioProject accession number in the Entrez query and click search. Then, click **Send to** on the top of the page, check the **Run Selector** radiobutton, and click the button **Go**. If necessary, refine your results by using various filters provided by the **Run Selector**'s interface. Click the **Metadata** button. This will generate a tabular **SraRunTable.csv** file with metadata available for each Run.
## Steps
1. Create the OTU_table (Sheet1 - OTU_table):\
The script uses the OTU_table from the unrarefied, concatenated (the three technical (PCR) replicates were concatenated by summation of the reads) and decontaminated eDNA metabarcoding data. First the additional columns containing the taxonomic classification and information about the taxonomic assignment are removed. Then the column ASV containing the names of the ASVs is renamed id, which is automatically recognized in the MDT. Lastly, the samples linked to the negative control samples are removed from the table to create the final OTU/ASV table.
2. Create the taxa-table (Sheet2 - Taxonomy):\
During this step the columns containing the OTU/ASV names, the taxonomic classification and information about the taxonomic assignment are selected from the OTU_table. The column ASV containing the names of the ASVs is renamed id, to be able to link it to the OTU/ASV table constructed in Step1, and the column containing the assigned species names (here: TaxonomicAssignment) is renamed scientificName, for automatic recognition by the MDT. Next the DNA_sequence, the length (len) and ASV number (asv) are added to the table by using the ASVs table generated while running the DADA2 pipeline. The column asv is moved to be the first column, followed by the column DNA_sequence, the sequence length and the taxonomic classification.
3. Create the samples-table (Sheet3 - Samples):\
The script uses the Attributes_Full table to add the metadata to each sample. 
In a first step the Attributes_Full table is adjusted, first row 11 is set as colnames and the first 10 rows with information about how to fill in the Attributes table are removed, after this all the empty columns are removed. The column “*collection_date” is renamed eventDate, such that it can be recognized by MDT and the columns with the BioSample accession (materialSampleID) and SRR accession (SRR_accession) number are added from the SRR table by using the unique sample names. With these accession numbers the links to the sample metadata and the sequences on NCBI can be created. To create the links to the metadata (SAMN_link) use the base url “ https://www.ncbi.nlm.nih.gov/biosample/ ” and add the BioSample accession number (materialSampleID) to it. To create the link to the sequences on SRA (SRR_link) use the base url “ https://www.ncbi.nlm.nih.gov/sra/ ” and add the SRR accession number (SRR_accession). In a last step the column “*lat_lon” (eg. 51.447917 N 3.2554 E) is split in two to create the columns decimalLatitude (eg. 51.447917 ) and demicalLongitude (eg. 3.2554) which can be recognized by MDT.\
During the second step, the samples table is created based on the formatted Attributes_Full table (Attributes). First, the columns of interest are selected, and the column sample_title, containing the sample names used in the colnames of the OTU/ASV table, is renamed id, to be able to link it to the OTU/ASV table (OTU_table) constructed in Step1. The column id is then filtered to keep only the samples present in the OTU/ASV table. In the ASV/OTU table the data of the three technical (PCR) replicates is concatenated, however in SRA the sequencing data from all three technical (PCR) replicates was uploaded separately. As a result the links to the sample metadata and to the sequences will be group together into one column. To do so first the data has to be grouped by id, eventDate, decimalLatitude and decimalLongitude. Once the data is grouped, the columns with the SAMN_link and SRR_link are reframed to contain all three links separated by “ | ” (eg. SAMN_link_PCR1 | SAMN_link_PCR2 | SAMN_link_PCR3)
5. Create the defaultValue-table (Sheet4 - Study):\
The default values are added manually to the table, through the lists term and value.
6. Save the file:\
All four tables are saved as separate sheets in one file in Excel-format (xlsx).
First a list is created in which all four tables are saved under the correct MDT name (OTU_table, Taxonomy, Samples and Study). This list is then saved as a xlsx file in the folder of interest, during this step each table in the list will be saved in a separate sheet, using the name needed to upload the data into the MDT.

## Upload to GBIF
Use the created template file to upload the eDNA metabarcoding data to https://edna-tool.gbif-uat.org/. More information about uploading the data can be found on: https://docs.gbif-uat.org/edna-tool-guide/en






