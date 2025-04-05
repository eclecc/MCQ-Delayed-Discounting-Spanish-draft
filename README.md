# mcq-delay-discounting-Gray-et-al.-2016

This repository provides a standardized procedure for estimating individual delay discounting rates (k) using the 27-item Monetary Choice Questionnaire (MCQ). It is based on the method introduced by **Gray et al. (2016)**.

---

## 🚀 Quick Start

If you're looking for the fastest and cleanest way to estimate *k* values from MCQ data, we recommend using the provided R function:

```r
source("calculate_discount_rate.R")

mcq_data <- read.table("Sample_MCQ_data.txt", header = TRUE)
lookup1 <- read.table("lookup1MCQ.txt", header = TRUE)
lookup2 <- read.table("lookup2MCQ.txt", header = TRUE)
lookup3 <- read.table("lookup3MCQ.txt", header = TRUE)

results <- calculate_discount_rate(mcq_data, lookup1, lookup2, lookup3)
```

This will return cleaned and log-transformed discounting indices.

---

## 🧩 Files Included

| File | Purpose |
|------|---------|
| `calculate_discount_rate.R` | Main R function for computing *k*, QC, and log10(k) |
| `Sample_MCQ_data.txt` | Example dataset with 27 MCQ items |
| `lookup1MCQ.txt` `lookup2MCQ.txt` `lookup3MCQ.txt` | Lookup tables for small, medium, and large blocks |
| `Final_MCQ_R_Syntax_logtrans.txt` | Legacy full script with line-by-line calculations (for transparency or manual step-through) |
| `README.md` | This instruction file |

---

## 📌 When to Use Which File?

| Scenario | Use This File |
|----------|----------------|
| You want a clean, reusable function for your own MCQ data | `calculate_discount_rate.R` |
| You want to understand the original logic in detail | `Final_MCQ_R_Syntax_logtrans.txt` |
| You are preparing your data and need a format example | `Sample_MCQ_data.txt` |
| You need the reference tables for response scoring | `lookup1MCQ.txt`, etc. |

---

## 🧭 Overview of Workflow

| Step | Action | Tool | Output |
|------|--------|------|--------|
| 1 | Format raw MCQ data (as `.txt`) | Excel / R | MCQ1–MCQ27 (1 = immediate, 2 = delayed) |
| 2 | Run function or full script | R | SmlK, MedK, LrgK |
| 3 | Compute geometric mean | R | k_geo |
| 4 | Apply QC (automatically) | R | Filtered dataset |
| 5 | Apply log10 transformation | R | log10(k_geo) |

---

## 📁 Input Format

Prepare a `.txt` file with the following:

- One row per participant
- Column 1: `SubjID` (optional)
- Columns 2–28: `MCQ1` to `MCQ27` (responses coded as 1 = immediate, 2 = delayed)

**Example:**
```
SubjID  MCQ1  MCQ2  ...  MCQ27  
001     2     1     ...   1
002     1     2     ...   2
```

---

## 🧠 Script Logic (for transparency)

The scoring procedure follows Gray et al. (2016) and includes:

1. Matching responses to 512 possible profiles per block (small/medium/large)
2. Retrieving the corresponding k value and internal consistency score
3. Computing the geometric mean of the three *k*s:  
   ```r
   k_geo = (SmlK * MedK * LrgK)^(1/3)
   ```
4. Applying QC:
   - Internal consistency ≥ 75% in all blocks
   - k_geo within ±3 SD of sample mean
5. Taking log10(k_geo)

---

## 📚 Reference

Gray, J. C., et al. (2016).  
*Syntax for calculation of discounting indices from the monetary choice questionnaire and probability discounting questionnaire.*  
**Journal of the Experimental Analysis of Behavior**, 106(3), 339–348.  
https://onlinelibrary-wiley-com.iclibezp1.cc.ic.ac.uk/doi/10.1002/jeab.221

---

