# mcq-delay-discounting-Gray-et-al.-2016 (Gray et al., 2016)

This repository provides a standardized procedure for estimating individual delay discounting rates (*k*) using the 27-item **Monetary Choice Questionnaire (MCQ)**, based on the syntax and lookup tables from **Gray et al. (2016)**.

---

## 📌 Objective

To ensure all team members calculate *k* values in a consistent, transparent, and replicable way.  
The final output is a **log10-transformed delay discounting rate** for each participant, suitable for use in downstream analyses (e.g., GWAS).

---

## 🧭 Overview of Workflow

| Step | Action                                                 | Tool         | Output                                           |
|------|--------------------------------------------------------|--------------|--------------------------------------------------|
| 1    | Format raw MCQ data                                    | Excel / `.txt` | `MCQ1–MCQ27` (1 = immediate, 2 = delayed)       |
| 2    | Run R script to estimate block-specific *k* values     | R            | *k*<sub>small</sub>, *k*<sub>medium</sub>, *k*<sub>large</sub> |
| 3    | Compute geometric mean across reward magnitudes        | R            | *k*<sub>geo</sub>                               |
| 4    | Apply quality filters                                  | R            | Filtered dataset                                |
| 5    | Apply `log10` transformation                           | R            | `log10(k_geo)`                                  |

---

## 📁 Input Format

Prepare a `.txt` file named `MCQdata.txt` with:

- Column 1: `SubjID`
- Columns 2–28: `MCQ1` to `MCQ27` (in original item order)
- Responses coded as:
  - `1` = immediate reward  
  - `2` = delayed reward

**Example:**
```
SubjID  MCQ1  MCQ2  ...  MCQ27  
001     2     1     ...   1
```

---

## 🧠 R Script Logic (Step-by-Step)

### 1. Estimate *k* per reward magnitude

Matches responses to one of 512 predefined choice profiles per block (small, medium, large).  
Extracts:
- `SmlK`, `MedK`, `LrgK`: magnitude-specific discounting rates
- `SmlCon`, `MedCon`, `LrgCon`: internal consistency scores

### 2. Compute geometric mean
```r
MCQdata$k_geo <- (MCQdata$SmlK * MCQdata$MedK * MCQdata$LrgK)^(1/3)
```

### 3. Apply quality control  
Participants are **excluded** if:
- Any consistency score is below 75%
- `k_geo` falls more than 3 SDs from the sample mean

```r
MCQdata_filtered <- subset(MCQdata, SmlCon >= 75 & MedCon >= 75 & LrgCon >= 75)

mean_k <- mean(MCQdata_filtered$k_geo, na.rm = TRUE)
sd_k <- sd(MCQdata_filtered$k_geo, na.rm = TRUE)

MCQdata_filtered <- subset(MCQdata_filtered,
  k_geo > (mean_k - 3 * sd_k) &
  k_geo < (mean_k + 3 * sd_k)
)
```

### 4. Apply `log10` transformation
```r
MCQdata_filtered$log10_k_geo <- log10(MCQdata_filtered$k_geo)
```

### 5. Export results
```r
write.table(MCQdata_filtered,
            file = "C:/Users/MCQindices_log_cleaned.txt",
            row.names = FALSE)
```

Final file: `MCQindices_log_cleaned.txt` contains cleaned and transformed *k* values.

---

## 📚 Reference

Gray, J. C., et al. (2016).  
*Syntax for calculation of discounting indices from the monetary choice questionnaire and probability discounting questionnaire.*  
**Journal of the Experimental Analysis of Behavior**, 106(3), 339–348.  
https://doi.org/10.1002/jeab.219

---
