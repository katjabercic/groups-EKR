# Installation

Assuming working SageMath and Gurobi installations:

Clone the repository or copy all files (except perhaps the data folder) into a common directory.

**Gurobi installation:** follow the instructions for the [free Academic Named-User License](https://www.gurobi.com/features/academic-named-user-license/).

# Running the script

To call the script with default parameters:

- `sage --python generate.py --out export/EKR_data.json` for MathDataHub JSON,
- `sage --python generate.py --no-mdh --out Data` to save data in the old format to the directory `Data`.

**Example:** compute EKR properties for groups up to order 100 for degrees from 3 to 10 and save them in MDH format to the file `export/EKR_data.json`.

```
sage --python generate.py --max-order 100 --max-degree 10 --out export/EKR_data.json
```

## Parameters

```
usage: generate.py [-h] [--max-order MAX_ORDER] [--min-degree MIN_DEGREE] [--max-degree MAX_DEGREE] --out OUT [--no-mdh] [--verbose]

optional arguments:
  -h, --help            show this help message and exit
  --max-order MAX_ORDER
                        Compute EKR properties for groups of at most this order (the default is 10)
  --min-degree MIN_DEGREE
                        Compute EKR properties for groups of at least this degree (the default is 3)
  --max-degree MAX_DEGREE
                        Compute EKR properties for groups of at most this degree (the default is 5)
  --out OUT             Output file for MDH, output directory for files by degree (required)
  --no-mdh              Export in MathDataHub JSON format
  --verbose             Print everything
```

## Notes

I was not able to figure out how to conver this into a pure Python script that just uses Sage as a library. The current solution uses the (mostly) original Sage files. The file `generate.py` was obtained from a Sage script and can be run by calling `sage --python generate.py` with parameters.

It may be beneficial to look at the `_solve_lp()` function in the `EKR Determiner.sage` file. It calls the command needed to run Gurobi. The exact command needed may change based on your system, so if any errors with Gurobi occur, this is the place to check.

