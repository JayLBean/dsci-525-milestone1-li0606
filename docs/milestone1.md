# DSCI 525 - Web and Cloud Computing

**General rule applicable for all milestones:** You can collaborate just as you would in the lab and need to submit your *individual* work. There are specific questions where you should work with a preferred lab partner(s) (you can pick up to 3 people from your class) to test things and get a feel for how it would look in the real world.

Note: You have two environment files in your student repo. For milestones, the only environment file you need is `525.yml`. The `525_dev.yml` file is only needed for running the lecture notes, as we are testing some experimental packages.

## Helper videos/notes for this milestone

- [https://pages.github.ubc.ca/mds-2025-26/DSCI_525_web-cloud-comp_book/lectures/l1a_rest_api.html#combine](https://pages.github.ubc.ca/mds-2025-26/DSCI_525_web-cloud-comp_book/lectures/l1a_rest_api.html#combine)

## Milestone 1: Tackling big data on your laptop

## Overall project goal and data 

During this course, you will be working on an *individual* project involving big data. The purpose is to get exposure to working with much larger datasets than you have previously in MDS. In particular, you will be building and deploying ensemble machine learning models in the cloud to predict daily rainfall in Australia on a large dataset (~6 GB), where features are outputs of different climate models, and the target is the actual rainfall observation.  


You will be using [this dataset on figshare](https://figshare.com/articles/dataset/Daily_rainfall_over_NSW_Australia/14096681). This folder has the output of different climate models as features, and our ultimate goal is to build an ensemble model on these outputs and compare the results with the actual rainfall. At the end of the project, you should have your ML model deployed in the cloud for others to use. 

During this course, you will work towards this goal step by step in four milestones.  

<br><br>

## Measurement helper

Paste this at the top of your notebook. Use `@measure` wherever Tasks 2, 3, and 3* ask you to compare run times.

```python
import time, psutil, os, functools

_proc = psutil.Process(os.getpid())

def measure(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        m0 = _proc.memory_info().rss / 1e6
        c0 = time.process_time()
        t0 = time.perf_counter()
        out = fn(*args, **kwargs)
        print(f"{fn.__name__}:  wall={time.perf_counter()-t0:.1f}s  "
              f"cpu={time.process_time()-c0:.1f}s  "
              f"mem Δ{_proc.memory_info().rss/1e6 - m0:+.0f} MB")
        return out
    return wrapper
```

Then decorate any function to measure it:

```python
@measure
def combine_csvs(folder):
    ...   # your implementation here

combine_csvs("data/")
```


- **wall** — real elapsed time
- **cpu** — time the processor was actually busy (I/O wait excluded)
- **mem Δ** — change in OS-level Memory (RAM) after the call (RSS)
- we don't have storage I/O estimate here, but when `wall >> cpu`, disk I/O is likely your bottleneck.



## Milestone 1 checklist

Part of the purpose of this milestone is to annoy you by making you work with large data in `Pandas` and vanilla CSV files. Typically these are not the best for dealing with large data. Along the way, you will also explore some useful tools for working with big data.


### 1. Downloading the data 
rubric={correctness:10}

1. Download the data from [figshare](https://figshare.com/articles/dataset/Daily_rainfall_over_NSW_Australia/14096681) (look at the URL, and you will see the `article_id` at the end) to your local computer using the [figshare API](https://docs.figshare.com) (you need to make use of `requests` library).

2. Extract the zip file, again programmatically, similar to how we did it in class. 

>  You can download the data and unzip it manually. But we learned about APIs, so we can do it in a reproducible way with the `requests` library, similar to how we [did it in class](https://pages.github.ubc.ca/mds-2025-26/DSCI_525_web-cloud-comp_book/lectures/l1a_rest_api.html#combine).

> There are 5 files in the figshare repo. The one we want is: `data.zip`


### 2. Combining data CSVs
rubric={correctness:10,reasoning:10}

1. Combine data CSVs into a single CSV using pandas.
    
2. When combining the CSV files, add an extra column called "model" that identifies the model.
    - Tip 1: you can get this column populated from the file name, eg: for file name "SAM0-UNICON_daily_rainfall_NSW.csv", the model name is SAM0-UNICON
    - Tip 2: Remember how we added "year" column when we combined airline CSVs. Here the regex will be to get word before an underscore ie, `"/([^_]*)"`

> Note: There is a file called `observed_daily_rainfall_SYD.csv` in the data folder that you downloaded. Make sure you exclude this file (programmatically or just take out that file from the folder) before you combine CSVs. We will use this file in our next milestone.

3. Wrap your combine function with `@measure` and ***compare*** wall time, CPU time, and memory across machines. Record results in the table below.

4. Based on the comparison, in 3–5 sentences, reflect on what you observe: how do the numbers differ across machines? What does the `wall`/`cpu` ratio tell you about where the bottleneck is? What surprised you?

> Warning: Some of you might not be able to do it on your laptop. It's fine if you're unable to do it. Just make sure you discuss the reasons why you might not have been able to run this on your laptop.

### 3. Load the combined CSV to memory and perform a simple EDA
rubric={correctness:10,reasoning:10}

1. Investigate at least two of the following approaches to reduce memory usage while performing the EDA (e.g., value_counts). 
    - Changing `dtype` of your data
    - Load just columns that we want
    - Loading in chunks
    
2. Wrap each approach with `@measure` and ***compare*** wall time, CPU time, and memory across machines. Record results in the table below.

3. Based on the comparison, in 3–5 sentences, reflect on what you observe: which approach was most effective at reducing memory? Did reducing memory come at a cost to wall time? Which approach would you choose in practice and why?

### 3* (Optional) Redo Task 3 with DuckDB
rubric={reasoning:5}

Use DuckDB to run the same EDA query directly on the combined CSV, without loading pandas. Materialize resulting data frame.

```python
import duckdb

@measure
def duckdb_eda():
    return duckdb.sql("""
        ...
    """).df()

result = duckdb_eda()
```

Compare the `@measure` output with your best pandas result from Task 3. In 3–5 sentences, explain: why is DuckDB's memory delta so much smaller? What does the `wall`/`cpu` ratio tell you compared to the pandas approaches? When would you prefer DuckDB over pandas for this kind of task?

### 4. Perform a simple EDA in R
rubric={correctness:15,reasoning:10}

1. Choose one of the methods listed below for transferring the dataframe (i.e., the entire dataset) from Python to R, and explain why you opted for this approach instead of the others.
    - [Parquet file](http://parquet.apache.org)
    - [Pandas exchange](https://rpy2.github.io/doc/latest/html/interactive.html)
    - [Arrow exchange](https://github.com/rpy2/rpy2-arrow)
2. Once you have the dataframe in R, perform a simple EDA.


>Note: If you encounter issues running both R and Python in a single notebook, or if you are unable to get rpy2 to work, you may consider alternative approaches. For example, you can save your data in a preferred format and then read it in RStudio (ensure that the required packages are installed manually). You can then copy the relevant R code back into the notebook and comment it out so that the notebook runs smoothly.

<br><br>

## Specific expectations for this milestone 

- In this milestone, we are looking for a well-documented and self-explanatory notebook that explores different options to tackle big data on your laptop.
- Please discuss any challenges or difficulties you faced when dealing with this large amount of data on your laptop. You can stop combining the data if it takes more than 30 minutes. Briefly explain your approach to overcoming the challenges or reasons why you could not overcome them.
- For questions 3 and 4, you are free to choose any exploratory data analysis (EDA) task you want. Visualization is not necessary; summarizing the data is enough. However, if you want to install additional packages for visualization that are not included in the .yml file, feel free to install them on top of your notebook. If you want to install packages in R, you can do so using `install.packages("dplyr")` under `%%R` magic cell.
- If someone in your team is facing issues with using R in a Python notebook, you can ignore it, as you will not need it for any other milestones. The main purpose of showing it in the lecture was to introduce and get a feel for the serialization and deserialization concept.
- You only need to ***compare*** the time with other team members for questions 2 and 3/3*. You do not need to do this for question 4. You can use the following table to record your results. Feel free to add any other relevant columns.


| Member | Approach | OS | RAM | Processor | SSD? | wall (s) | cpu (s) | mem Δ (MB) |
|:------:|:--------:|:--:|:---:|:---------:|:----:|:--------:|:-------:|:----------:|
| 1 (you) | combine | | | | | | | |
| 2 | combine | | | | | | | |
| 3 | combine | | | | | | | |
| 4 | combine | | | | | | | |
| 1 (you) | approach 1 | | | | | | | |
| 1 (you) | approach 2 | | | | | | | |
| 2 | approach 1 | | | | | | | |
| 2 | approach 2 | | | | | | | |
| ... | ... | | | | | | | |


<br><br>
## Submission instructions
rubric={mechanics:5}

Upload `.ipynb`, `.html`, and `.pdf` files of your milestone1 notebook to Canvas (remember it is not Gradescope).

As a comment include
- The GitHub URL to your GitHub repo.