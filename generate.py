import logging as log
from argparse import ArgumentParser

from sage.all import *
from sage.all_cmdline import *   

default_max_order = 10
default_min_degree = 3
default_max_degree = 5
_sage_const_max_order = Integer(default_max_order)
_sage_const_min_degree = Integer(default_min_degree)
_sage_const_max_degree = Integer(default_max_degree)
# import sage library
load("Common.sage")
load("DeterminerEKR.sage")
load("DeterminerEKRM.sage")
load("DeterminerEKRStrict.sage")
load("DataGenerator.sage")

max_order = _sage_const_max_order 
min_deg = _sage_const_min_degree 
max_deg = _sage_const_max_degree 

if __name__ == "__main__":
    
    arg_parser = ArgumentParser()
    arg_parser.add_argument("--max-order", type=int, default=_sage_const_max_order, dest="max_order",
                        help=f"Compute EKR properties for groups of at most this order (the default is {default_max_order})")
    arg_parser.add_argument("--min-degree", type=int, default=_sage_const_min_degree, dest="min_degree",
                        help=f"Compute EKR properties for groups of at least this degree (the default is {default_min_degree})")
    arg_parser.add_argument("--max-degree", type=int, default=_sage_const_max_degree, dest="max_degree",
                        help=f"Compute EKR properties for groups of at most this degree (the default is {default_max_degree})")
    arg_parser.add_argument("--out", dest="out", required=True,
                        help="Output file for MDH, output directory for files by degree (required)")
    arg_parser.add_argument("--no-mdh", dest="notmdh", action="store_true",
                        help="Export in MathDataHub JSON format") # default to MDH format
    arg_parser.add_argument("--verbose", dest="verbose", action="store_true",
                        help="Print everything") # default to MDH format
    args = arg_parser.parse_args()

    if args.verbose:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
        log.info("Verbose output.")
    else:
        log.basicConfig(format="%(levelname)s: %(message)s")

    groups_to_test = []
    for degree in range(args.min_degree, args.max_degree + 1):
        groups_to_test += [G for G in TransitiveGroups(degree) if G.order() <= args.max_order]
    DataGenerator(groups_to_test, args.out, mdh=(not args.notmdh))
