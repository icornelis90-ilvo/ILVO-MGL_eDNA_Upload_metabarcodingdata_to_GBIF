###### Isolde Cornelis
###### 03/07/2025
###### Create the template file to upload data to the from eDNA metabarcoding to GBIF

### activate libraries
library(vegan)
library(seqRFLP)
library(dplyr)
library(tibble)
library(stringr)
library(here)

### make paths
proj.path.GBIF <- here("/home/genomics/icornelis/07_GBIF/02_Uploading-Files/")
proj.path.data <- here("/home/genomics/icornelis/07_GBIF/03_Input-Files/")

### upload data
# OTU-tables and taxa (standard files created by the dada2 pipeline)
OTU_table <- readxl::read_excel(paste0(proj.path.data,"table_unrarefied_concatenated_CleanedASVs_WithField_FullTaxonomicAssignment.xlsx"))
ASVs <- read.table(paste0(proj.path.data,"asvs.tsv"), header = T)

## samples
# The MIMARCKS file created to upload data to NCBI
Attributes_Full <- readxl::read_excel(paste0(proj.path.data,"Attributes_NJ2021_12S.xlsx"))
#file to be downloaded from NCBI 
SRR <- read.csv(paste0(proj.path.data,"SraRunInfo_NJ2021_Option1-File.csv"), header = T, sep = ";") #Option1
#SRR <- read.csv(paste0(proj.path.data,"SraRunTable_NJ2021_Option2-RunSelector.csv"), header = T, sep = ";") %>%  #Option2
  #rename("SampleName" = "Sample.Name")

###Get data
##OTU_table
OTU <- OTU_table %>%
  #Remove columns with information about the taxonomic classification
  select(!Kingdom:Comment) %>% 
  #rename the column ASV to id
  rename(id = ASV) %>%
  #remove columns from negative control samples
  select(!contains("neg"))

##taxa
taxa <- OTU_table %>%
  #Select columns with information about the taxonomic classification
  select(ASV:Comment) %>%  
  rename(id = ASV, #rename the column ASV to id
         scientificName = TaxonomicAssignment) %>% #rename the column TaxonomicAssignment to scientificName
  #group_by id to consider each group separately 
  group_by(id) %>%
  #add the ASV sequences to the taxonomic information
  mutate(DNA_sequence = ASVs$dnas[which(ASVs$names== id)], 
         len = ASVs$len[which(ASVs$names==id)],
         asv = ASVs$asv[which(ASVs$names==id)]) %>% 
  ungroup() %>%
  #move the column "asv" to the first position
  select(asv, everything()) %>% 
  #move the columns "DNA_sequence" and "len" before the column "Kingdom"
  relocate(c(DNA_sequence, len), .before = Kingdom)

##samples
#Adjust the Attributes table
Attributes <- Attributes_Full %>%
  #add colnames to the Attribute table (row 11)
  scrutiny::row_to_colnames(11) %>%
  #remove the heading of the Attribute table (first 11 rows)
  filter(!is.na(sample_title)) %>%
  #remove empty columns from the Attribute table
  select_if(function(x) !(all(is.na(x)))) %>%
  #change the colname of "*collection_date" to "eventDate"
  rename(eventDate = `*collection_date`) %>%
  #group_by "*sample_name" to consider each name separately
  group_by(`*sample_name`) %>%
  #Add the SRR and biosample accession numbers from NCBI to the attributes table
  mutate(materialSampleID = ifelse(`*sample_name` %in% SRR$`SampleName`,
                                   SRR$BioSample[which(SRR$`SampleName`==`*sample_name`)],
                                   ""),
         SRR_accession = ifelse(`*sample_name` %in% SRR$`SampleName`,
                               SRR$Run[which(SRR$`SampleName`==`*sample_name`)],
                               "")) %>%
  ungroup() %>%
  mutate(SRR_link = ifelse(SRR_accession == "", 
                           "",
                           paste("https://www.ncbi.nlm.nih.gov/sra/",
                                 SRR_accession,
                                 sep="")), #add ncbi link to the reads
         SAMN_link = ifelse(materialSampleID == "", 
                            "", 
                            paste("https://www.ncbi.nlm.nih.gov/biosample/", 
                                  materialSampleID, 
                                  sep="")), #add ncbi link to the samples
         #add Latitude
         decimalLatitude = ifelse(`*lat_lon` == "not applicable",
                                  `*lat_lon`, stringr::word(`*lat_lon`, 1)),
         #add Longitude
         decimalLongitude = ifelse(`*lat_lon` == "not applicable",
                                   `*lat_lon`, stringr::word(`*lat_lon`, 3)))

#create table new table to add the information for the samples sheet
samples <- Attributes %>%
  #keep only the columns of interest from the Attributes table
  select(sample_title, eventDate, decimalLatitude, decimalLongitude,
         SRR_link, SAMN_link) %>%
  #rename the column sample_title to id
  rename(id = sample_title) %>%
  #keep only unique rows, this removes double ids due to the PCR replicates
  #distinct() %>%
  #filter to keep only the samples present in the OTU table 
  filter(., id %in% colnames(OTU)) %>%
  #group by the columns with same informatie for each PCR replicate
  group_by(id, eventDate, decimalLatitude, decimalLongitude) %>%
  #summarise the data for the ncbi links for the PCR replicates per samples and separate them by |
  reframe(associatedSequences = paste(SRR_link, collapse = " | "),
          materialSampleID = paste(SAMN_link, collapse = " | ")) %>%
  #for some samples the sequences were not uploaded to NCBI (unused in the paper)
  #leave the columns "associatedSequences" and "materialSampleID" empty
  mutate(associatedSequences = ifelse(associatedSequences == " |  | ", 
                                      "", 
                                      associatedSequences),
         materialSampleID = ifelse(materialSampleID == " |  | ", 
                                    "",
                                    materialSampleID))

##Study
defaultValue <- data.frame(
  #add the terms that need to be filled in in GBIF
  term = c("env_broad_scale",
           "env_medium",
           "target_gene",
           "pcr_primer_forward",
           "pcr_primer_name_forward",
           "pcr_primer_reverse",
           "pcr_primer_name_reverse",
           "seq_meth",
           "lib_layout",
           "otu_class_appr",
           "otu_seq_comp_appr",
           "otu_db"),
  #add the values to be filled in for each term (adjust where needed for your data)
  value = c("marine biome",
            "seawater",
            "12S rRNA",
            "5’-GT(C/T)GGTAAA(A/T)CTCGTGCCAGC-3’",
            "MiFish_U/E_F",
            "5’-CATAGTGGGGTATCTAATCC(C/T)AGTTTG-3’",
            "MiFish_U/E_R",
            "Illumina MiSeq",
            "Paired",
            "dada2;1.14.0;ASV",
            "blastn;2.6.0+ | assignTaxonomy;dada2;1.14.0",
            "custom made reference database"))
            
### Save the data into one file
list_of_datasets <- list("OTU_table" = OTU,
                         "Taxonomy" = taxa,
                         "Samples" = samples,
                         "Study" = defaultValue)
openxlsx::write.xlsx(list_of_datasets, paste0(proj.path.GBIF,"/edna_template_filled.xlsx"), colNames = T)
