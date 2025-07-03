# eDNA_metabarcoding_Upload-to-GBIF

## Description
This script allows you to fill in the template file, in excel format, needed to upload the eDNA metabarcoding data to GBIF (https://edna-tool.gbif-uat.org/).
The template file consists of 4 sheets:
* Sheet1 = OTUtable\
The OTU table each row must represent a unique OTU, and each column must represent a different sample or site, with the cell values indicating the count of sequencing reads of the OTUs in each sample. The OTU table will be linked to the two other tables
* Sheet2 = taxa\
The taxa table relates to the OTUs and must contain at least the sequence, but likely also the taxonomic classification. The order of the OTUs in the OTU- and taxa table must be the same
* Sheet3 = samples\
The sample table contains the metadata relating to the samples/sites. The order of the samples must in the OTU-table (columns) and samples-table (rows) must be the same
* Sheet4 = defaultValue\
Add the values you want to add in GBIF, such as target sequence, used primers and sequencing method, etc

## Needed input files
1. OTU_table:\
ASV table containing the unrarefied and concatenated data after decontamination of the contaminant ASVs\
Rows are the ASVs and the Columns are the samples\
The first columns contain the taxonomic classification, ASV-name, and the results after taxonomic assignment with DADA2 and BLASTn against the costumn reference database and BLASTn against GenBank
2. ASVs:\
Table, generated while running DADA2, that contains all the:\
&emsp; - ASV-names (names)\
&emsp; - ASV-sequences (dnas)\
&emsp; - ASV-lengths (len)
3. Attributes_Full:\
The complete MIMARCKS file created to upload the sequencing data to NCBI
4. SRR:\
The metadata file containing the SRA accessions, which can be downloaded from the bioproject on NCBI

## Steps
1. Create the OTU_table (Sheet1):\
The script uses the ASVs from the unrarefied, concatenated and cleaned ASV-table. The last 11 cloumns with the taxonomic classification and all negative control samples will be removed. ASVs without reads will be removed from the ASV-table.
2. Create the taxa-table (Sheet2):\
The script uses the last 11 columns of the ASV-table that contain the taxonomic classification. The columns "Species" and "ASV" are renamed to "scientificName" and "id", in order to be automatically recognized by GBIF. The column "id" is moved to the first position. Afterwards the ASV-sequence and length are added before the column "Kingdom"
3. Create the samples-table (Sheet3):\
The script uses the Attributes table to add the metadata to each sample. In addition, the links to the sequencing file (associatedSequence) and sample metadata (materialSampleID) on SRA are added. Since the concatenated samples are used, the links for all three PCR/technical replicates, separated by "|", are added for each sample
4. Create the defaultValue-table (Sheet4):\
The default values are added manually to the table, through the lists term and value.
5. Save the file:\
All four tables are saved as seperate sheets in on file in Excel-format (xlsx). 

## Upload to GBIF
Use the created template file to upload the eDNA metabarcoding data to https://edna-tool.gbif-uat.org/. More information about uploading the data can be found on: https://docs.gbif-uat.org/edna-tool-guide/en
