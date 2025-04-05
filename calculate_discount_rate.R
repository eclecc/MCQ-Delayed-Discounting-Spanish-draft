#' calculate_discount_rate
#'
#' This function calculates discount rate (k) from Monetary Choice Questionnaire (MCQ) responses.
#' It supports 27-item MCQ based on Gray et al. (2016), using three lookup tables for small, medium, and large reward blocks.
#' It returns individual-level k estimates, internal consistency scores, and filters the data based on our project's standard QC criteria.
#'
#' @param mcq_data A dataframe with columns MCQ1 to MCQ27 (coded as 1 = immediate, 2 = delayed)
#' @param lookup1 Lookup table for small reward block
#' @param lookup2 Lookup table for medium reward block
#' @param lookup3 Lookup table for large reward block
#'
#' @return A cleaned dataframe with k values, internal consistency, and log10(k_geo)

calculate_discount_rate <- function(mcq_data, lookup1, lookup2, lookup3) {
  # Step 1: Ensure input data format is correct
  stopifnot(is.data.frame(mcq_data))
  required_cols <- paste0("MCQ", 1:27)
  missing_cols <- setdiff(required_cols, colnames(mcq_data))
  if (length(missing_cols) > 0) {
    stop(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
  }

  # Step 2: Calculate encoded sequence value for each reward block
  # This is done using predefined binary weights for each item within the block
  # Subtracting 510 centers the sequence in the correct range (0–511)
  mcq_data$SmlSeq <- with(mcq_data,
                          MCQ13*1 + MCQ20*2 + MCQ26*4 + MCQ22*8 + MCQ3*16 +
                          MCQ18*32 + MCQ5*64 + MCQ7*128 + MCQ11*256 - 510)

  mcq_data$MedSeq <- with(mcq_data,
                          MCQ1*1 + MCQ6*2 + MCQ24*4 + MCQ16*8 + MCQ10*16 +
                          MCQ21*32 + MCQ14*64 + MCQ8*128 + MCQ27*256 - 510)

  mcq_data$LrgSeq <- with(mcq_data,
                          MCQ9*1 + MCQ17*2 + MCQ12*4 + MCQ15*8 + MCQ2*16 +
                          MCQ25*32 + MCQ23*64 + MCQ19*128 + MCQ4*256 - 510)

  mcq_data$id <- seq_len(nrow(mcq_data))  # Record original row order so we can return to it after merging

  # Step 3: Merge in lookup tables
  mcq_data <- merge(lookup1, mcq_data, by = "SmlSeq")
  mcq_data <- merge(lookup2, mcq_data, by = "MedSeq")
  mcq_data <- merge(lookup3, mcq_data, by = "LrgSeq")
  mcq_data <- mcq_data[order(mcq_data$id), ]

  # Step 4: Compute geometric mean of k values
  mcq_data$k_geo <- (mcq_data$SmlK * mcq_data$MedK * mcq_data$LrgK)^(1/3)

  # Step 5: Apply QC filters
  # Filter 1: Internal consistency ≥ 75%
  mcq_data <- subset(mcq_data, SmlCons >= 0.75 & MedCons >= 0.75 & LrgCons >= 0.75)

  # Filter 2: Remove extreme outliers (k > ±3 SD)
  mean_k <- mean(mcq_data$k_geo, na.rm = TRUE)
  sd_k <- sd(mcq_data$k_geo, na.rm = TRUE)
  mcq_data <- subset(mcq_data,
                     k_geo > (mean_k - 3 * sd_k) &
                     k_geo < (mean_k + 3 * sd_k))

  # Step 6: Apply log10 transformation
  mcq_data$log10_k_geo <- log10(mcq_data$k_geo)

  return(mcq_data)
