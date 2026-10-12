#!/usr/bin/env python3
"""Polarize a VCF using ancify ancestral FASTA files.

Usage:
    python polarize_vcf.py \
        --anc-dir ancestral_calls/ \
        --vcf input.vcf.gz \
        --out polarized.vcf.gz
"""

import argparse
from pathlib import Path

from cyvcf2 import VCF, Writer
from ancify.utils import read_fasta


def load_ancestral(anc_dir):
    """Load all ancestral FASTA files into a dict keyed by chromosome name."""
    seqs = {}
    for fa in Path(anc_dir).glob("*.fa"):
        chrom = fa.stem
        _, seqs[chrom] = read_fasta(fa)
    return seqs


def polarize(vcf_path, anc_dir, out_path, high_confidence_only=False):
    vcf = VCF(str(vcf_path))
    vcf.add_info_to_header({
        "ID": "AA",
        "Number": "1",
        "Type": "String",
        "Description": "Ancestral allele inferred by ancify",
    })
    vcf.add_info_to_header({
        "ID": "DAF",
        "Number": "1",
        "Type": "String",
        "Description": "Derived allele: REF or ALT (or . if ambiguous)",
    })

    w = Writer(str(out_path), vcf)
    ancestral = load_ancestral(anc_dir)

    counts = {"ref_ancestral": 0, "alt_ancestral": 0, "nomatch": 0, "skipped": 0}

    for v in vcf:
        seq = ancestral.get(v.CHROM)
        if seq is None or v.POS - 1 >= len(seq):
            counts["skipped"] += 1
            w.write_record(v)
            continue

        allele = seq[v.POS - 1]
        if high_confidence_only and not allele.isupper():
            counts["skipped"] += 1
            w.write_record(v)
            continue

        anc = allele.upper()
        if anc not in "ACGT":
            counts["skipped"] += 1
            w.write_record(v)
            continue

        v.INFO["AA"] = anc

        if len(v.ALT) == 1 and len(v.REF) == 1 and len(v.ALT[0]) == 1:
            if anc == v.REF:
                v.INFO["DAF"] = "ALT"
                counts["ref_ancestral"] += 1
            elif anc == v.ALT[0]:
                v.INFO["DAF"] = "REF"
                counts["alt_ancestral"] += 1
            else:
                v.INFO["DAF"] = "."
                counts["nomatch"] += 1

        w.write_record(v)

    w.close()
    vcf.close()

    total = sum(counts.values())
    print(f"Polarized {total:,} variants:")
    print(f"  REF is ancestral:  {counts['ref_ancestral']:>10,}")
    print(f"  ALT is ancestral:  {counts['alt_ancestral']:>10,}")
    print(f"  No match:          {counts['nomatch']:>10,}")
    print(f"  Skipped:           {counts['skipped']:>10,}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Polarize VCF with ancestral alleles")
    parser.add_argument("--anc-dir", required=True, help="Directory with ancestral chr*.fa files")
    parser.add_argument("--vcf", required=True, help="Input VCF (optionally gzipped)")
    parser.add_argument("--out", required=True, help="Output VCF path")
    parser.add_argument("--high-only", action="store_true",
                        help="Only use high-confidence calls (uppercase)")
    args = parser.parse_args()
    polarize(args.vcf, args.anc_dir, args.out, high_confidence_only=args.high_only)