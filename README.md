# mcq-delay-discounting-Gray-et-al.-2016

This repository provides a standardized procedure for estimating individual delay discounting rates (*k*) using the 27-item Monetary Choice Questionnaire (MCQ). It is based on the method introduced by **Gray et al. (2016)**.

---

## 🚀 Quick Start

If you're looking for the fastest way to estimate *k* values, we recommend using the provided R function:

```r
source("calculate_discount_rate.R")

mcq_data <- read.table("Sample_MCQ_data.txt", header = TRUE)
lookup1 <- read.table("lookup1MCQ.txt", header = TRUE)
lookup2 <- read.table("lookup2MCQ.txt", header = TRUE)
lookup3 <- read.table("lookup3MCQ.txt", header = TRUE)

results <- calculate_discount_rate(mcq_data, lookup1, lookup2, lookup3)
```

This will return log-transformed discounting indices.

---

## 🧩 Files Included

| File | Purpose |
|------|---------|
| `calculate_discount_rate.R` | Main R function for computing *k*, QC, and log10(k) |
| `Sample_MCQ_data.txt` | Example dataset with 27 MCQ items |
| `lookup1MCQ.txt` `lookup2MCQ.txt` `lookup3MCQ.txt` | Lookup tables for small, medium, and large blocks |
| `Final_MCQ_R_Syntax_logtrans.txt` | Full script with line-by-line calculations |
| `README.md` | Instruction file |

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
| 4 | Apply QC  | R | Filtered dataset |
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

The calculation procedure follows Gray et al. (2016), and includes the following steps:

### 1. Encode response profiles

Each block of 9 items (small, medium, large rewards) is scored by converting the binary response pattern (1 = immediate, 2 = delayed) into a unique numerical identifier called a “sequence code”.

This is done by:
- Assigning a binary weight to each item (e.g. 1, 2, 4, 8, ..., 256)
- Summing the weighted responses
- Subtracting 510 to normalize the code (since 2s are treated as 1s in binary)

This produces three variables: `SmlSeq`, `MedSeq`, and `LrgSeq`.

### 2. Match response sequences to lookup tables

Each `Seq` value is matched against a pre-computed lookup table containing:
- The corresponding *k* value that best fits that response pattern
- An internal consistency score (0–1), measuring how consistent the choices are within that block

These values are added to the dataset as:
- `SmlK`, `MedK`, `LrgK`: estimated discount rates per reward magnitude
- `SmlCons`, `MedCons`, `LrgCons`: internal consistency per block

### 3. Compute a single summary k-value

A geometric mean is used to combine the three *k* values into a single metric:

```r
k_geo = (SmlK * MedK * LrgK)^(1/3)
```

This provides a participant-level measure of delay discounting across all magnitudes.

### 4. Apply quality control (QC)

Two filters are applied to ensure valid responses:

- **Internal consistency filter**: Participants must have ≥ 75% consistency in all three blocks.
- **Outlier filter**: Participants with `k_geo` values outside ±3 SD of the sample mean are excluded.

These filters are applied automatically in the function.

### 5. Log transformation

Finally, the cleaned `k_geo` value is log-transformed to improve normality and prepare for downstream analyses:

```r
log10_k_geo = log10(k_geo)
```

---

This entire procedure can be reproduced manually using `Final_MCQ_R_Syntax_logtrans.txt`, or automatically using the `calculate_discount_rate()` function.


## 📚 Reference

Gray, J. C., et al. (2016).  
*Syntax for calculation of discounting indices from the monetary choice questionnaire and probability discounting questionnaire.*  
**Journal of the Experimental Analysis of Behavior**, 106(3), 339–348.  
https://onlinelibrary-wiley-com.iclibezp1.cc.ic.ac.uk/doi/10.1002/jeab.221

---

