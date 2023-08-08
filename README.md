# EKR Properties 

Assuming working SageMath and Gurobi installations:

1. Copy all files (except perhaps the data folder) into a common directory
2. Using the Sage shell, navigate to this directory and attach the `attach.sage` file

```
attach("attach.sage")
```

From the Sage shell you now have access to all the needed code. It may also be beneficial to look at the `_solve_lp()` function in the `EKR Determiner.sage` file. It calls the command needed to run Gurobi. The exact command needed may change based on your system, so if any errors with Gurobi occur, this is the place to check.

```
attach("attach.sage")
max_order = 100
for degree in range(3, 5):
    groups_to_test = [G for G in TransitiveGroups(degree) if G.order() <= max_order]
    Data_Generator(groups_to_test, mdh=True)
```

## Gurobi installation

Follow the instructions for the [free Academic Named-User License](https://www.gurobi.com/features/academic-named-user-license/).